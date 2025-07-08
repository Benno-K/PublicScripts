<?php
// Enable error display for debugging
// ini_set('display_errors', 1);
// ini_set('display_startup_errors', 1);
// error_reporting(E_ALL);

// ----------- CONFIGURATION -----------
$repoRoot = '/home/pi/gitrepos'; // All git repos in this directory
$styleDir = __DIR__ . '/webgit-style';
$styleWebPath = '/webgit-style'; // Web-accessible path (relative to script location)
$gitBin   = '/home/pi/gitrepos/webgit'; // Use your setuid git copy here

// ----------- UTILS -----------
function themesAvailable($styleDir) {
    $themes = [];
    foreach (glob($styleDir . '/*-theme.css') as $css) {
        $name = basename($css);
        if (preg_match('/^(.*)-theme\.css$/', $name, $m)) {
            $themes[$m[1]] = $name;
        }
    }
    return $themes;
}
function getTheme() {
    if (!empty($_COOKIE['theme']) && preg_match('/^[a-zA-Z0-9_-]+$/', $_COOKIE['theme'])) {
        return $_COOKIE['theme'];
    }
    return 'dark'; // Default
}
function setThemeHeader($themes, $theme, $styleWebPath) {
    if (isset($themes[$theme])) {
        echo '<link rel="stylesheet" href="' . $styleWebPath . '/' . htmlspecialchars($themes[$theme]) . '" id="themecss">';
    } else {
        $first = reset($themes);
        if ($first) {
            echo '<link rel="stylesheet" href="' . $styleWebPath . '/' . htmlspecialchars($first) . '" id="themecss">';
        }
    }
}
function sanitizeRepo($repo) {
    return preg_replace('/[^\w.-]/', '', $repo);
}
function repoExists($repoRoot, $repo) {
    return is_dir("$repoRoot/$repo/.git");
}
function ansi2html($ansi) {
    $ansi = htmlspecialchars($ansi);
    $map = [
        "\033[1;31m" => '<span class="git-red">',
        "\033[31m"   => '<span class="git-red">',
        "\033[1;32m" => '<span class="git-green">',
        "\033[32m"   => '<span class="git-green">',
        "\033[1;33m" => '<span class="git-yellow">',
        "\033[33m"   => '<span class="git-yellow">',
        "\033[1;36m" => '<span class="git-cyan">',
        "\033[36m"   => '<span class="git-cyan">',
        "\033[1m"    => '<span class="git-bold">',
        "\033[0m"    => '</span>',
        "\033[m"     => '</span>',
    ];
    $ansi = preg_replace_callback('/(\033\[[0-9;]*m)/', function($m) use ($map) {
        return $map[$m[1]] ?? '';
    }, $ansi);
    #$ansi .= str_repeat('</span>', substr_count($ansi, '<span') - substr_count($ansi, '</span>'));

		$open = substr_count($ansi, '<span');
		$close = substr_count($ansi, '</span>');
		if ($open > $close) {
			    $ansi .= str_repeat('</span>', $open - $close);
		}

    return nl2br($ansi);
}

// ----------- ROUTING LOGIC -----------
$repo = isset($_GET['repo']) ? sanitizeRepo($_GET['repo']) : null;
$commit = isset($_GET['commit']) ? preg_replace('/[^0-9a-f]/i', '', $_GET['commit']) : null;
$themes = themesAvailable($styleDir);
$theme = getTheme();

if (!$repo) {
    $level = 1;
} else if ($repo && !$commit) {
    $level = 2;
} else if ($repo && $commit) {
    $level = 3;
} else {
    $level = 1;
}

// ----------- DATA FETCHING -----------
if ($level == 1) {
    // List all repos
    $repos = [];
    foreach (scandir($repoRoot) as $r) {
        if ($r[0] == '.' || !repoExists($repoRoot, $r)) continue;
        $repos[] = $r;
    }
    sort($repos, SORT_NATURAL | SORT_FLAG_CASE);
} elseif ($level == 2 && repoExists($repoRoot, $repo)) {
    // Get commit list
    $cmd = sprintf('%s -C %s log --pretty=format:"%%h|%%ad|%%an|%%s" --date=short --no-color 2>&1',
        escapeshellarg($gitBin), escapeshellarg("$repoRoot/$repo"));
    $gitlog = shell_exec($cmd);
    $commits = [];
    if ($gitlog) {
        foreach (explode("\n", trim($gitlog)) as $line) {
            $parts = explode('|', $line, 4);
            if (count($parts) === 4) {
                $commits[] = ['hash' => $parts[0], 'date' => $parts[1], 'author' => $parts[2], 'subject' => $parts[3]];
            }
        }
    }
} elseif ($level == 3 && repoExists($repoRoot, $repo)) {
    // Get commit diff and message
    $cmd = sprintf('%s -C %s show --color=always %s 2>&1',
        escapeshellarg($gitBin), escapeshellarg("$repoRoot/$repo"), escapeshellarg($commit));
    $diff = shell_exec($cmd);
    // Get commit message only
    $msg = '';
    $cmd2 = sprintf('%s -C %s log -1 --pretty=format:"%%s" %s 2>&1',
        escapeshellarg($gitBin), escapeshellarg("$repoRoot/$repo"), escapeshellarg($commit));
    $msg = trim(shell_exec($cmd2));
    // For left nav
    $cmd3 = sprintf('%s -C %s log --pretty=format:"%%h|%%ad|%%an|%%s" --date=short --no-color 2>&1',
        escapeshellarg($gitBin), escapeshellarg("$repoRoot/$repo"));
    $gitlog = shell_exec($cmd3);
    $commits = [];
    if ($gitlog) {
        foreach (explode("\n", trim($gitlog)) as $line) {
            $parts = explode('|', $line, 4);
            if (count($parts) === 4) {
                $commits[] = ['hash' => $parts[0], 'date' => $parts[1], 'author' => $parts[2], 'subject' => $parts[3]];
            }
        }
    }
}

// ----------- ERROR HANDLING -----------
$notfound = false;
if (($level == 2 || $level == 3) && !repoExists($repoRoot, $repo)) {
    $notfound = true;
} elseif ($level == 3 && empty($diff)) {
    $notfound = true;
}

// ----------- HTML -----------
?><!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>GitWeb<?php
        if ($level==2 && $repo) echo ': '.htmlspecialchars($repo);
        if ($level==3 && $repo && $commit) echo ': '.htmlspecialchars($repo).' '.htmlspecialchars($commit);
    ?></title>
    <?php setThemeHeader($themes, $theme, $styleWebPath); ?>
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
    /* Only structure/neutral layout styles here. All colors in theme files */
    #headline-row {
        display: flex; align-items: center; justify-content: space-between;
        padding: 1em 2vw 0.8em 2vw; min-height: 3.3em;
        border-bottom: 1px solid var(--border-color);
        background: var(--headline-bg);
        position: sticky; top: 0; z-index: 10;
    }
    #headline-row .hl-left, #headline-row .hl-center, #headline-row .hl-right { flex: 1 1 0; }
    #headline-row .hl-center { text-align: center; font-size: 1.3em; font-weight: 600; letter-spacing: 0.04em; }
    #headline-row .hl-left { text-align: left;}
    #headline-row .hl-right { text-align: right;}
    .levelup-btn {
        display: inline-block; background: var(--btn-bg); color: var(--btn-fg);
        border: none; padding: 0.42em 1.3em; border-radius: 7px; font-size: 1.09em;
        font-weight: 500; text-decoration: none; transition: background 0.13s, transform 0.12s;
        margin-right: 0.6em;
    }
    .levelup-btn:hover { background: var(--btn-bg-hover); transform: scale(1.05);}
    .theme-switcher {
        display: inline-block; background: var(--btn-bg); color: var(--btn-fg);
        border: none; padding: 0.42em 1.3em; border-radius: 7px; font-size: 1.09em;
        font-weight: 500; cursor: pointer; position: relative;
        text-decoration: none; margin-left: 0.6em;
        transition: background 0.13s, transform 0.12s;
    }
    .theme-switcher:hover { background: var(--btn-bg-hover); transform: scale(1.05);}
    .theme-popup {
        display: none; position: absolute; top: 110%; right: 0; min-width: 9em;
        background: var(--popup-bg); border: 1px solid var(--border-color);
        box-shadow: 0 4px 24px #0005; padding: 0.4em 0;
        border-radius: 6px; z-index: 100;
    }
    .theme-popup.show { display: block;}
    .theme-popup .theme-item {
        display: block; color: var(--btn-fg); padding: 0.45em 1.2em; border: none;
        background: none; width: 100%; text-align: left; font-size: 1.06em;
        cursor: pointer; transition: background 0.11s;
        border-radius: 3px;
    }
    .theme-popup .theme-item.selected { font-weight: 600; color: var(--btn-bg-hover);}
    .theme-popup .theme-item:hover { background: var(--btn-bg-hover); color: var(--btn-fg);}
    @media print {
        .theme-switcher, .theme-popup, .levelup-btn { display: none !important;}
        #headline-row { border-bottom: none !important;}
    }
    .subheadline { text-align: center; font-size: 1.18em; margin: 2em 0 1.2em 0; color: var(--subheadline-color);}
    .nav-content-layout {
        display: flex; flex-direction: row; align-items: stretch; min-height: 80vh;
    }
    .nav-pane {
        flex: 0 0 18em; max-width: 25vw; min-width: 12em; background: var(--nav-bg);
        border-right: 1px solid var(--border-color); padding: 1.5em 1em 1em 1.3em;
    }
    .main-pane {
        flex: 1 1 0; padding: 2em 3vw 3em 3vw; min-width: 0;
    }
    @media (max-width: 900px) {
        .nav-content-layout { flex-direction: column; }
        .nav-pane, .main-pane { max-width: 100vw; border: none; padding-left: 1em;}
    }
    body {
        background: var(--body-bg);
        color: var(--body-color);
    }
    .git-diff {
        background: var(--diff-bg);
        padding: 1.1em 1.2em;
        border-radius: 7px;
        margin: 2em 3vw 1em 3vw;
        font-family: 'JetBrains Mono', 'Fira Mono', 'Menlo', monospace;
        font-size: 1.05em;
        overflow-x: auto;
        box-shadow: 0 0 12px #0004;
        border: 1px solid var(--border-color);
        line-height: 1.61;
    }
    .git-red { color: var(--git-red);}
    .git-green { color: var(--git-green);}
    .git-yellow { color: var(--git-yellow);}
    .git-cyan { color: var(--git-cyan);}
    .git-bold { font-weight: bold;}
    </style>
</head>
<body>
<div id="headline-row">
    <div class="hl-left">
        <?php if ($level==2): ?>
            <a href="gitweb.php" class="levelup-btn">&larr; Repository List</a>
        <?php elseif ($level==3): ?>
            <a href="gitweb.php?repo=<?=urlencode($repo)?>" class="levelup-btn">&larr; Commits</a>
        <?php endif; ?>
    </div>
    <div class="hl-center">
        <?php if ($level==1): ?>
            Repository List
        <?php elseif ($level==2): ?>
            <?=htmlspecialchars($repo)?>
        <?php elseif ($level==3): ?>
            <?=htmlspecialchars($repo)?>: <span style="font-family:monospace;"><?=htmlspecialchars($commit)?></span>
        <?php endif; ?>
    </div>
    <div class="hl-right">
        <div style="display:inline-block; position:relative;">
            <button class="theme-switcher" id="themeBtn"><?=htmlspecialchars($theme)?> &#x25BC;</button>
            <div class="theme-popup" id="themePopup" role="menu">
                <?php foreach ($themes as $t => $css): ?>
                    <button class="theme-item<?php if($t==$theme)echo' selected';?>" data-theme="<?=htmlspecialchars($t)?>">
                        <?=ucfirst(htmlspecialchars($t))?>
                    </button>
                <?php endforeach; ?>
            </div>
        </div>
    </div>
</div>
<?php if ($level==3 && isset($msg) && $msg): ?>
    <div class="subheadline"><?=htmlspecialchars($msg)?></div>
<?php endif; ?>

<?php
// ----------- MAIN CONTENT -----------

// Level 1: Repo list
if ($level == 1): ?>
    <div class="main-pane">
        <?php if (empty($repos)): ?>
            <div>No repositories found in <code><?=htmlspecialchars($repoRoot)?></code>.</div>
        <?php else: ?>
            <h2 style="margin-top:0;">Repositories</h2>
            <ul style="list-style:none; padding:0; margin:0;">
            <?php foreach($repos as $r): ?>
                <li style="margin-bottom:1.1em;">
                    <a href="gitweb.php?repo=<?=urlencode($r)?>" class="levelup-btn" style="font-size:1.08em;">
                        <?=htmlspecialchars($r)?>
                    </a>
                </li>
            <?php endforeach; ?>
            </ul>
        <?php endif; ?>
    </div>
<?php
// Level 2: Commit list for repo
elseif ($level == 2 && !$notfound): ?>
    <div class="nav-content-layout">
        <div class="nav-pane">
            <div style="font-size:1.2em; font-weight:600; color:var(--subheadline-color); margin-bottom:1em;">
                <?=htmlspecialchars($repo)?>
            </div>
            <ul style="list-style:none; padding:0;">
            <?php foreach ($commits as $c): ?>
                <li style="margin-bottom:0.39em;">
                    <a href="gitweb.php?repo=<?=urlencode($repo)?>&commit=<?=$c['hash']?>" class="levelup-btn" style="font-family:monospace; font-size:1em;"><?=htmlspecialchars($c['hash'])?></a>
                </li>
            <?php endforeach; ?>
            </ul>
        </div>
        <div class="main-pane">
            <h2 style="margin-top:0;">Commit History</h2>
            <?php if (empty($commits)): ?>
                <div>No commits found in this repo.</div>
            <?php else: ?>
                <div>
                <?php foreach ($commits as $c): ?>
                    <div style="padding:0.31em 0; border-bottom:1px solid var(--border-color); display:flex; align-items:center; gap:0.8em;">
                        <span style="min-width:8ch;">
                            <a href="gitweb.php?repo=<?=urlencode($repo)?>&commit=<?=htmlspecialchars($c['hash'])?>" class="levelup-btn" style="font-family:monospace; font-size:1em;">
                                <?=htmlspecialchars($c['hash'])?>
                            </a>
                        </span>
                        <span style="color:var(--meta-date); min-width:8ch;"><?=htmlspecialchars($c['date'])?></span>
                        <span style="color:var(--meta-author); min-width:8ch;"><?=htmlspecialchars($c['author'])?></span>
                        <span style="color:var(--meta-subject); margin-left:0.5em; flex:1;"><?=htmlspecialchars($c['subject'])?></span>
                    </div>
                <?php endforeach; ?>
                </div>
            <?php endif; ?>
        </div>
    </div>
<?php
// Level 3: Commit diff
elseif ($level == 3 && !$notfound): ?>
    <div class="nav-content-layout">
        <div class="nav-pane">
            <div style="font-size:1.2em; font-weight:600; color:var(--subheadline-color); margin-bottom:1em;">
                <?=htmlspecialchars($repo)?>
            </div>
            <ul style="list-style:none; padding:0;">
            <?php foreach ($commits as $c): ?>
                <li style="margin-bottom:0.39em;">
                    <a href="gitweb.php?repo=<?=urlencode($repo)?>&commit=<?=$c['hash']?>" class="levelup-btn" style="font-family:monospace; font-size:1em;<?=($c['hash']==$commit?' background:var(--btn-bg-hover);':'')?>">
                        <?=htmlspecialchars($c['hash'])?>
                    </a>
                </li>
            <?php endforeach; ?>
            </ul>
        </div>
        <div class="main-pane">
            <div style="margin-bottom:2em;">
                <span style="font-size:1.16em; color:var(--subheadline-color); font-weight:600;"><?=htmlspecialchars($repo)?> / <span style="font-family:monospace;"><?=htmlspecialchars($commit)?></span></span>
            </div>
            <div class="git-diff"><?=ansi2html($diff)?></div>
        </div>
    </div>
<?php
// Not found
else: ?>
    <div class="main-pane">
        <h2>Not found</h2>
        <div>The page you wanted does not exist or is not available.</div>
        <div style="margin-top:2em;">
            <a href="gitweb.php" class="levelup-btn">Go to Repository List</a>
        </div>
    </div>
<?php endif; ?>

<script>
const themeBtn = document.getElementById('themeBtn');
const themePopup = document.getElementById('themePopup');
if (themeBtn && themePopup) {
    themeBtn.addEventListener('click',function(e){
        e.stopPropagation();
        themePopup.classList.toggle('show');
    });
    themeBtn.addEventListener('mouseenter',function(){
        themeBtn.title = "Click to switch theme";
    });
    document.addEventListener('click',function(e){
        if(!themePopup.contains(e.target) && e.target!==themeBtn) {
            themePopup.classList.remove('show');
        }
    });
    themePopup.querySelectorAll('.theme-item').forEach(function(btn){
        btn.addEventListener('click',function(){
            var theme = btn.getAttribute('data-theme');
            document.cookie = "theme=" + encodeURIComponent(theme) + ";path=/;max-age=31536000";
            location.reload();
        });
        btn.addEventListener('mouseenter',function(){
            let altTheme = btn.textContent.trim();
            themeBtn.title = "Click to switch to " + altTheme + " theme";
        });
        btn.addEventListener('mouseleave',function(){
            themeBtn.title = "Click to switch theme";
        });
    });
}
</script>
</body>
</html>
