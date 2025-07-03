$! diskmon.com -- OpenVMS DCL disk usage monitor with named parameters
$!
$! Usage:
$!   $ @DISKMON /THRESH=10 /QUIET /FS=DUA0:,DUA1:
$!   $ @DISKMON /FS=DUA0:
$!   $ @DISKMON /HELP
$!
$ ON ERROR THEN GOTO ErrExit
$ ON CONTROL_Y THEN GOTO ErrExit
$!
$! --------- Default values ---------
$ Thresh = "5"
$ Quiet = "0"
$ FsList = ""
$ ShowHelp = "0"
$!
$! --------- Argument Parsing Loop ---------
$ I = 1
$ParseLoop:
$ Arg = F$EDIT( F$STRING(P'I'), "TRIM,UPCASE" )
$ IF Arg .EQS. "" THEN GOTO ParseDone
$   IF Arg .EQS. "/HELP" .OR. Arg .EQS. "-H" .OR. Arg .EQS. "--HELP" THEN ShowHelp = "1"
$   IF F$LOCATE("/THRESH=",Arg) .EQ. 0 THEN Thresh = F$ELEMENT(1,"=",Arg)
$   IF Arg .EQS. "/QUIET" .OR. Arg .EQS. "/Q" THEN Quiet = "1"
$   IF F$LOCATE("/FS=",Arg) .EQ. 0 THEN FsList = F$ELEMENT(1,"=",Arg)
$ I = I + 1
$ GOTO ParseLoop
$ParseDone:
$ IF ShowHelp .EQ. "1" THEN GOTO ShowHelpLabel
$!
$! --------- If no /FS= provided, try to load state ---------
$ StateFile = F$LOGICAL("SYS$LOGIN") + "DISKMON_STATE.DAT"
$ IF FsList .EQS. "" THEN GOTO TryLoadState
$ GOTO AfterLoadState
$TryLoadState:
$ OPEN/READ/ERROR=NoState StateIn 'StateFile'
$ReadState:
$  READ/END=StateDone StateIn Rec
$  Key = F$ELEMENT(0,"=",Rec)
$  Val = F$ELEMENT(1,"=",Rec)
$  IF Key .EQS. "savedThreshold" THEN Thresh = Val
$  IF Key .EQS. "savedCmdLine" THEN FsList = Val
$  GOTO ReadState
$StateDone:
$ CLOSE StateIn
$ GOTO AfterLoadState
$NoState:
$   WRITE SYS$ERROR "Usage: @DISKMON /THRESH=n /QUIET /FS=DUA0:,DUA1: ..."
$   EXIT 44
$AfterLoadState:
$! --------- Save command line as new default ---------
$ OPEN/WRITE StateOut 'StateFile'
$ WRITE StateOut "savedThreshold=''Thresh'"
$ WRITE StateOut "savedCmdLine=''" + FsList + "'"
$!
$! --------- Prepare for state lookup ---------
$! Load previous states for each fs into an array
$ FsInitArr = ""
$ OPEN/READ/ERROR=NoPrevState StateIn 'StateFile'
$ReadPrevLoop:
$  READ/END=ReadPrevDone StateIn Rec
$  Key = F$ELEMENT(0,"=",Rec)
$  Val = F$ELEMENT(1,"=",Rec)
$  IF F$LOCATE("initial_percent_",Key) .EQ. 0 THEN -
      FsInitArr = FsInitArr + F$EXTRACT(16,255,Key) + "|" + Val + "~"
$  GOTO ReadPrevLoop
$ReadPrevDone:
$ CLOSE StateIn
$NoPrevState:
$!
$! --------- Main Monitoring Loop ---------
$ FsIdx = 0
$NextFs:
$ Fs = F$ELEMENT(FsIdx, ",", FsList)
$ IF Fs .EQS. "" THEN GOTO AllDone
$ SafeFs = Fs
$ SafeFs = F$TRANSLATE(SafeFs,"__","[]:.;-")
$ SafeFs = "FS_" + SafeFs
$! Find previous
$ PrevPercent = "0"
$ PrevDate = ""
$ I = 0
$FindIni:
$ K = F$ELEMENT(I,"~",FsInitArr)
$ IF K .EQS. "" THEN GOTO IniFound
$ Kfs = F$ELEMENT(0,"|",K)
$ IF Kfs .EQS. SafeFs
$ THEN
$   PrevPercent = F$ELEMENT(1,"|",K)
$   PrevDate = F$ELEMENT(2,"|",K)
$   GOTO IniFound
$ ENDIF
$ I = I + 1
$ GOTO FindIni
$IniFound:
$! F$GETDVI for info
$ TotalBlocks = F$GETDVI(Fs,"MAXBLOCKS")
$ IF TotalBlocks .EQS. "" THEN TotalBlocks = F$GETDVI(Fs,"TOTBLOCKS")
$ FreeBlocks = F$GETDVI(Fs,"FREEBLOCKS")
$ IF TotalBlocks .EQS. "" .OR. FreeBlocks .EQS. ""
$ THEN
$   WRITE SYS$OUTPUT Fs + ":"
$   WRITE SYS$OUTPUT " ! Not found"
$   GOTO UpdateState
$ ENDIF
$ UsedBlocks = TotalBlocks - FreeBlocks
$ Percent = 100 - ((FreeBlocks * 100) / TotalBlocks)
$ Percent = F$STRING(F$INTEGER(Percent))
$ Now = F$TIME()
$ Now = F$EXTRACT(0,2,Now) + "." + -
        F$EXTRACT(3,2,Now) + "." + F$EXTRACT(6,2,Now) + "/" + -
        F$EXTRACT(9,2,Now) + "." + F$EXTRACT(12,2,Now)
$ IF PrevPercent .EQS. "0"
$ THEN
$   WRITE SYS$OUTPUT Fs + ":"
$   WRITE SYS$OUTPUT " ''Percent'% f:''FreeBlocks' u:''UsedBlocks'"
$   WRITE SYS$OUTPUT " rec:''Now' trg:''Now'"
$   GOTO UpdateState
$ ENDIF
$ IF Quiet .EQS. "0"
$ THEN
$   WRITE SYS$OUTPUT Fs + ":"
$   WRITE SYS$OUTPUT " now ''Percent'% was ''PrevPercent'% f:''FreeBlocks' u:''UsedBlocks'"
$   WRITE SYS$OUTPUT " rec:''PrevDate' trg:''Now'"
$ ENDIF
$ Diff = Percent - PrevPercent
$ IF Diff .LT. 0 THEN Diff = -Diff
$ IF Diff .GT. Thresh
$ THEN
$   WRITE SYS$OUTPUT Fs + ":"
$   WRITE SYS$OUTPUT " ''PrevPercent'%->''Percent'% thr:''Thresh'%"
$   WRITE SYS$OUTPUT " f:''FreeBlocks' u:''UsedBlocks'"
$   WRITE SYS$OUTPUT " rec:''PrevDate' trg:''Now'"
$   GOTO UpdateState
$ ENDIF
$ GOTO NextFs
$UpdateState:
$! Save state for this fs
$ WRITE StateOut "initial_percent_''SafeFs'=''Percent'|''Now'"
$ GOTO NextFs
$AllDone:
$ CLOSE StateOut
$ EXIT
$ShowHelpLabel:
$ WRITE SYS$ERROR "Usage: @DISKMON /THRESH=n /QUIET /FS=DUA0:,DUA1: ..."
$ WRITE SYS$ERROR " /THRESH=n   - integer percent threshold (default 5)"
$ WRITE SYS$ERROR " /QUIET      - suppress non-threshold output"
$ WRITE SYS$ERROR " /FS=devs    - comma separated disk device names"
$ WRITE SYS$ERROR " /HELP       - this message"
$ EXIT 3
$ErrExit:
$ WRITE SYS$ERROR "An error occurred, aborting."
$ EXIT 2
