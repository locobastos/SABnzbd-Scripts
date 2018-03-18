####################################################################################################
# SUMARY :                                                                                         #
#    This script rename files with the current folder's name and move files on the parent folder.  #
####################################################################################################

#_____VAR___________________________________________________________________________________________

LOG="/usr/local/sabnzbd/var/scripts/MoveRename.log"
DIRECTORY="/volume1/downloads/complete"
HISTORY="$DIRECTORY/MoveRenameHistory.log"

FULL_JOB_DIRECTORY=$1

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
                echo "Moved $F to $FOLDER_NAME.$FILE_EXT" >> $HISTORY
        else
                mv "${F}" "../$FOLDER_NAME-$FILENAME$FILE_EXT"
                echo `date "+%d.%m.%Y %H:%M:%S"` "---I--- : Moved '${F}' to '../$FOLDER_NAME-$FILENAME$FILE_EXT'" >> $LOG
                echo "Moved $F to $FOLDER_NAME-$FILENAME$FILE_EXT" >> $HISTORY
        fi
done

rm -r "$FULL_JOB_DIRECTORY"

#_____END__________________________________________________________________________________________

echo "---------- END ----------" >> $LOG
echo "" >> $LOG
