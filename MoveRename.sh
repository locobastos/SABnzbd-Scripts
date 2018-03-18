####################################################################################################
# SUMARY :                                                                                         #
#    This script rename files with the current folder's name and move files on the parent folder.  #
#                                                                                                  #
# BASIC PARAMETERS :                                                                               #
#    The script will receive the parameters described below.                                       #
#    Use %1 in Windows scripts and $1 in Unix scripts.                                             #
#    Note that on Windows the input parameters are surrounded by quotes (e.g. "job name").         #
#                                                                                                  #
#    1  The final directory of the job (full path)                                                 #
#    2  The original name of the NZB file                                                          #
#    3  Clean version of the job name (no path info and ".nzb" removed)                            #
#    4  Indexer's report number (if supported)                                                     #
#    5  User-defined category                                                                      #
#    6  Group that the NZB was posted in e.g. alt.binaries.x                                       #
#    7  Status of post processing.                                                                 #
#           0 = OK                                                                                 #
#           1 = Failed verification                                                                #
#           2 = Failed unpack                                                                      #
#           3 = 1+2                                                                                #
#           -1 = Failed post processing                                                            #
#    8  URL to be called when job failed                                                           #
#       (if provided by the server, it is always sent, so check parameter 7!).                     #
#       The URL is provided by some indexers as the X-DNZB-Failure header                          #
#                                                                                                  #
# ENVIROMENT VARIABLES :                                                                           #
#    Your script can get extra information via environment variables:                              #
#                                                                                                  #
#    SAB_SCRIPT             The name of the current script                                         #
#    SAB_NZO_ID             The unique ID assigned to the job                                      #
#    SAB_FINAL_NAME         The name of the job in the queue and of the final folder               #
#    SAB_FILENAME           The NZB filename (after grabbing from the URL)                         #
#    SAB_COMPLETE_DIR       The whole path to the output directory of the job                      #
#    SAB_PP_STATUS          Was post-processing succesfully completed                              #
#                           (repair and/or unpack, if enabled by user)                             #
#    SAB_CAT                What category was assigned                                             #
#    SAB_BYTES              Total number of bytes                                                  #
#    SAB_BYTES_TRIED        How many bytes of the total bytes were tried                           #
#    SAB_BYTES_DOWNLOADED   How many bytes were recieved (can be more than tried, due to overhead) #
#    SAB_DUPLICATE          Was it detected as duplicate                                           #
#    SAB_UNWANTED_EXT       Were there unwanted extensions                                         #
#    SAB_OVERSIZED          Was the job over the user's size limit                                 #
#    SAB_PASSWORD           What was the password supplied by the NZB or the user                  #
#    SAB_ENCRYPTED          Was the job detected as encrypted                                      #
#    SAB_STATUS             Current status (completed/failed/running)                              #
#    SAB_FAIL_MSG           If job failed, why did it fail                                         #
#    SAB_AGE                Average age of the articles in the post                                #
#    SAB_URL                URL from which the NZB was retrieved                                   #
#    SAB_AVG_BPS            Average bytes/second speed during active downloading                   #
#    SAB_DOWNLOAD_TIME      How many seconds did we download                                       #
#    SAB_PP                 What post-processing was activated (download/repair/unpack/delete)     #
#    SAB_REPAIR             Was repair selected by user                                            #
#    SAB_UNPACK             Was unpack selected by user                                            #
#    SAB_FAILURE_URL        Provided by some indexers as alternative NZB if download fails         #
#    SAB_PRIORITY           Priority set by user                                                   #
#    SAB_GROUP              Newsgroup where (most of) the job's articles came from                 #
#    SAB_VERSION            The version of SABnzbd used                                            #
#                                                                                                  #
#    v2.3.1+ Enviroment variables below were added in SABnzbd 2.3.1.                               #
#    SAB_ORIG_NZB_GZ        Path to the original NZB-file of the job.                              #
#                           The NZB-file is compressed with gzip (.gz)                             #
#    SAB_PROGRAM_DIR        The directory where the current SABnzbd instance is located            #
#    SAB_PAR2_COMMAND       The path to the par2 command on the system that SABnzbd uses           #
#    SAB_MULTIPAR_COMMAND   Windows-only (empty on other systems). The path to the MultiPar        #
#                           command on the system that SABnzbd uses                                #
#    SAB_RAR_COMMAND        The path to the unrar command on the system that SABnzbd uses          #
#    SAB_ZIP_COMMAND        The path to the unzip command on the system that SABnzbd uses          #
#    SAB_7ZIP_COMMAND       The path to the 7z command on the system that SABnzbd uses.            #
#                           Not all systems have 7zip installed (it's optional for SABnzbd),       #
#                           so this can also be empty                                              #
#                                                                                                  #
# SOURCE :                                                                                         #
#    https://sabnzbd.org/wiki/scripts/post-processing-scripts                                      #
####################################################################################################

#_____VAR___________________________________________________________________________________________

LOG="/usr/local/sabnzbd/var/scripts/MoveRename.log"
DIRECTORY="/volume1/downloads/complete"
HISTORY="$DIRECTORY/MoveRenameHistory.log"

SCRIPT_NAME=$0
FULL_JOB_DIRECTORY=$1
ORIGINAL_NZB_NAME=$2
CLEAN_JOB_NAME=$3
INDEXER_REPORT_NUMBER=$4
USER_DEFINED_CATEGORY=$5
NZB_GROUP=$6
STATUS_POST_PROCESSING=$7
URL_FAILED_JOB_FAILED=$8

#_____BEGIN_________________________________________________________________________________________

echo "---------- BEGIN ----------" >> $LOG
cd "$FULL_JOB_DIRECTORY"

for F in "$FULL_JOB_DIRECTORY"/*.*
do
    echo `date "+%d.%m.%Y %H:%M:%S"` "---I--- : Current folder :" `pwd` >> $LOG

        FOLDER_NAME=`basename "$PWD"`
    FILE_EXT="${F##*.}"
        FILENAME=`basename $F $FILE_EXT`

    echo `date "+%d.%m.%Y %H:%M:%S"` "---I--- : FOLDER_NAME :" $FOLDER_NAME >> $LOG
        echo `date "+%d.%m.%Y %H:%M:%S"` "---I--- : FILENAME :" $FILENAME >> $LOG
    echo `date "+%d.%m.%Y %H:%M:%S"` "---I--- : FILE_EXT :" $FILE_EXT >> $LOG

        if [ ! -f "../$FOLDER_NAME.$FILE_EXT" ]
        then
                mv "${F}" "../$FOLDER_NAME.$FILE_EXT"
                echo `date "+%d.%m.%Y %H:%M:%S"` "---I--- : Moved '${F}' to '../$FOLDER_NAME.$FILE_EXT'" >> $LOG
        else
                mv "${F}" "../$FOLDER_NAME-$FILENAME$FILE_EXT"
                echo `date "+%d.%m.%Y %H:%M:%S"` "---I--- : Moved '${F}' to '../$FOLDER_NAME-$FILENAME$FILE_EXT'" >> $LOG
        fi
done

#_____END__________________________________________________________________________________________

echo "---------- END ----------" >> $LOG
echo "" >> $LOG
