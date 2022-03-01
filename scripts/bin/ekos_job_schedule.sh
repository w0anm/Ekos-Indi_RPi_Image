#!/bin/bash

# Author: Chris Kovacs
# Date Created:
# Last Modified:2022.01.07
# Version: 0.1a
# Description:
   # This script creates exposure and  target sequences for ekos.
   # This script does not support multiple jobs or mosaics jobs.
   #

# Usage: ekos_job_schedule.sh

####### Configuration of equipment #######

MAIN_CCD="ZWO CCD ASI533MC Pro"
EQUIP_PROFILE="astro-iEQ45Pro-WO73_int"
FILTER_WHEEL=""       # need to be setup
GUIDE_DEV="3.0"
GUIDE_START_DEV="2.0"

####### started start condition #######
START_CONDITION="ASAP"

####### date/time condition #######
#START_DATE="2021-08-30"
#START_TIME="00:20:00"
#START_CONDITION="value='${START_DATE}T${START_TIME}'>At"

####### Startup and Shutdown Process #######
STARTUP_PROCEDURE="<Procedure>UnparkMount</Procedure>"

####### File setup #######
FITS_DIRECTORY=~/Kstars/Astro_Working
SEQ_DIR=~/Kstars/Job_Sequences

ESQFILE=""

# Misc.
## Num  Colour    #define         R G B
## 
## 0    black     COLOR_BLACK     0,0,0
## 1    red       COLOR_RED       1,0,0
## 2    green     COLOR_GREEN     0,1,0
## 3    yellow    COLOR_YELLOW    1,1,0
## 4    blue      COLOR_BLUE      0,0,1
## 5    magenta   COLOR_MAGENTA   1,0,1
## 6    cyan      COLOR_CYAN      0,1,1
## 7    white     COLOR_WHITE     1,1,1

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
blue=$(tput setaf 4)
magenta=$(tput setaf 5)
cyan=$(tput setaf 6)
white=$(tput setaf 7)
reset=$(tput sgr0)

## # example:
## echo "${red}red text ${green}green text"
## echo "${magenta}magenta text ${cyan}cyan text"
## echo "${yellow}yellow text ${blue}blue text${reset}"

JOBNUM=$(date +%M%S)

clear

echo "${cyan}Script Based Upon the ZWO asi533 Camera${reset}"
echo

# Functions 

# File Selection Function
FileSelect() {
  echo "${yellow}Please select a file.${reset}"

  n=0
  for esqfile in ${SEQ_DIR}/*.esq
  do
    n=$((n+1))
    printf "[%s] %s\n" "$n" "$esqfile"
    eval "esqfile${n}=\$esqfile"
  done

  if [ "$n" -eq 0 ]
  then
    echo >&2 No images found.
    exit
  fi

  echo -n "${yellow}"
  printf 'Enter File Index ID (1 to %s): ' "$n"
  read -r num
  num=$(printf '%s\n' "$num" | tr -dc '[:digit:]')

  if [ "$num" -le 0 ] || [ "$num" -gt "$n" ]
  then
    echo >&2 "${red}Wrong selection. ${reset}"
    exit 1
  else
    eval "ESQFILE=\$esqfile${num}"
  fi
  echo -n "${reset}"

}

# ckyorn function with defaults
ckyorn () {
    return=0
    if [ "$1" = "y" ] ; then
        def="y"
        sec="n"
    else
        def="n"
        sec="y"
    fi

    while [ $return -eq 0 ]
    do
        read -e -p "([$def],$sec): ? " answer
        case "$answer" in
                "" )    # default
                        printf "$def"
                        return=1 ;;
        [Yy])   # yes
                        printf "y"
                        return=1
                        ;;
        [Nn] )   # no
                        printf "n"
                        return=1
                        ;;
                   *)   printf "    ERROR: Please enter y, n or return.  " >&2
                        printf ""
                        return=0 ;;
        esac
    done

}


# Create Exposure Sequence

CreateExposureSeq() {
  #default values
  EXPOSURE_DEF=90
  CAMTEMP_DEF=-10
  FILTER_DEF="Lum"
  TYPE_DEF="Light"
  RAWPREFIX_DEF="new"
  IMGCOUNT_DEF=30
  GAIN_DEF=100
  OFFSET_DEF=10
  REFOCUS=60

  echo
  echo "${green}***** Setup Camera Exposure Sequence *****"
  echo

  echo -n "${white}Set Exposure Time [$EXPOSURE_DEF]: ${yellow}" ; read EXPOSURE
  if [ -z "$EXPOSURE" ] ; then
      EXPOSURE=$EXPOSURE_DEF
  fi

  echo -n "${white}Number of Images in Session [$IMGCOUNT_DEF]: ${yellow}" ; read IMGCOUNT
  if [ -z "$IMGCOUNT" ] ; then
      IMGCOUNT=$IMGCOUNT_DEF
  fi

  echo -n "${white}Set Camera Temperature [$CAMTEMP_DEF]: ${yellow}" ; read CAMTEMP
  if [ -z "$CAMTEMP" ] ; then
      CAMTEMP=$CAMTEMP_DEF
  fi

  echo -n "${white}Type of Image (Light, Dark, Flat, Bias) [$TYPE_DEF]: ${yellow}" ; read TYPE
  if [ -z "$TYPE" ] ; then
      TYPE=$TYPE_DEF
  fi

  echo -n "${white}Image Raw Prefix Name [$RAWPREFIX_DEF]: ${yellow}" ; read RAWPREFIX
  if [ -z "$RAWPREFIX" ] ; then
      RAWPREFIX=$RAWPREFIX_DEF
  fi

  echo -n "${white}Camera Gain [$GAIN_DEF]: ${yellow}" ; read GAIN
  if [ -z "$GAIN" ] ; then
      GAIN=$GAIN_DEF
  fi

  echo -n "${white}Camera Offset [$OFFSET_DEF]: ${yellow}" ; read OFFSET
  if [ -z "$OFFSET" ] ; then
      OFFSET=$OFFSET_DEF
  fi

  # if filter is defined as -- then skip below
  if [ -n "$FILTER" ] ; then
      echo -n "${white}Filter Select (${white}Lum, ${red}Red, ${green}Green, ${blue}Blue, ${cyan}HA-7nm${white}) [$FILTER_DEF]: ${yellow}" ; read FILTER
      if [ -z "$FILTER" ] ; then
          FILTER=$FILTER_DEF
      fi
      # Setup file name
      EXPOSURE_SEQ=${SEQ_DIR}/${RAWPREFIX}_${FILTER}_${EXPOSURE}s_${IMGCOUNT}c_${GAIN}g_${OFFSET}o.esq
  else
      FILTER_XML="--"
      # Setup file name, remove FILTER from name
      EXPOSURE_SEQ=${SEQ_DIR}/${RAWPREFIX}_${EXPOSURE}s_${IMGCOUNT}c_${GAIN}g_${OFFSET}o.esq
  fi  

  #Header
  cat << _EOF > $EXPOSURE_SEQ
<?xml version="1.0" encoding="UTF-8"?>
<SequenceQueue version='2.1'>
<CCD>ZWO CCD ASI533MC Pro</CCD>
<FilterWheel>--</FilterWheel>
<GuideDeviation enabled='true'>${GUIDE_DEV}</GuideDeviation>
<GuideStartDeviation enabled='true'>${GUIDE_START_DEV}</GuideStartDeviation>
_EOF

  # Focus
  cat <<_EOF >> $EXPOSURE_SEQ
<Autofocus enabled='false'>0</Autofocus>
<RefocusOnTemperatureDelta enabled='true'>2</RefocusOnTemperatureDelta>
<RefocusEveryN enabled='false'>${REFOCUS}</RefocusEveryN>
_EOF

  #Job
  cat << _EOF >> $EXPOSURE_SEQ
<Job>
<Exposure>${EXPOSURE}</Exposure> 
<Binning>
<X>1</X>
<Y>1</Y>
</Binning>
<Frame>
<X>0</X>
<Y>0</Y>
<W>3008</W>
<H>3008</H>
</Frame>
<Temperature force='true'>${CAMTEMP}</Temperature>
<Type>${TYPE}</Type>
<Prefix>
<RawPrefix>${RAWPREFIX}</RawPrefix>
<FilterEnabled>0</FilterEnabled>
<ExpEnabled>1</ExpEnabled>
<TimeStampEnabled>1</TimeStampEnabled>
</Prefix>
<Count>${IMGCOUNT}</Count>
<Delay>0</Delay>
<FITSDirectory>${FITS_DIRECTORY}</FITSDirectory>
<UploadMode>0</UploadMode>
<FormatIndex>0</FormatIndex>
<Properties>
<NumberVector name='CCD_CONTROLS'>
<OneNumber name='Gain'>${GAIN}</OneNumber>
<OneNumber name='Offset'>${OFFSET}</OneNumber>
</NumberVector>
</Properties>
<Calibration>
<FlatSource>
<Type>Manual</Type>
</FlatSource>
<FlatDuration>
<Type>ADU</Type>
<Value>6000</Value>
<Tolerance>1000</Tolerance>
</FlatDuration>
<PreMountPark>False</PreMountPark>
<PreDomePark>False</PreDomePark>
</Calibration>
</Job>
_EOF

  echo "</SequenceQueue>" >> $EXPOSURE_SEQ

  # echo "${red}red text ${green}green text${reset}"
  clear
  echo "${magenta}***Summary*****************************************************************"
  echo "${green}   Sequence Prefix: ${white}${RAWPREFIX}"
  echo "${green}   Filter:          ${white}${FILTER}"
  echo "${green}   Exposure:        ${white}${EXPOSURE}"
  echo "${green}   Image Count:     ${white}${IMGCOUNT}"
  echo "${green}   Gain:            ${white}${GAIN}"
  echo "${green}   Offset:          ${white}${OFFSET}"

  TOT_EXP_SS=$(echo "${EXPOSURE} * ${IMGCOUNT};" | bc)
  TOT_EXP_MIN=$(echo "scale=0; ${TOT_EXP_SS} / 60;" | bc) 
  TOT_EXP_HR=$(echo "scale=1; ${TOT_EXP_MIN} / 60; " | bc)

  echo "${green}   Exposure Time:   ${white}${TOT_EXP_MIN} min or ${TOT_EXP_HR} hr"
  echo "${green}   File Created:    ${white}${EXPOSURE_SEQ}"
  echo "${magenta}***************************************************************************${reset}"
  echo
  echo -n "${yellow}Continue?" ; read ans
  echo ${reset} 
  echo

}

CreateJobSequence() {

  # loop to re-edit if necessary
  AGAIN="Y"
  while [ "$AGAIN" = "Y" ] ; do
      # Object Name
      echo -n "${white}Enter Target Name: ${yellow}" ; read TARGET

      # RA Coordinates
      echo -n "${white}Enter RA Coordinates (0 42 44.3): ${yellow}" ; read RA

      # DEC Coordinates
      echo -n "${white}Enter DEC Coordinates (41 16 08): ${yellow}" ; read DEC

      # Select Options, Track, Align, Focus, Guide  (Focus is the only optional step
      echo -n "${white}Do you want to set 'Focus' during sequence steps ${yellow}"; ANS=$(ckyorn n)
      if [ "$ANS" = "n" ] ; then
          FOCUS_OPT=
      else
          FOCUS_OPT="<Step>Focus</Step>"
      fi


      # use awk to split the values
      RAhr=$(echo $RA | awk '{print $1}')
      RAmin=$(echo $RA | awk '{print $2}')
      RAsec=$(echo $RA | awk '{print $3}')

      DECdeg=$(echo $DEC | awk '{print $1}')
      DECmin=$(echo $DEC | awk '{print $2}')
      DECsec=$(echo $DEC | awk '{print $3}')

      # Convert Coordinates to decimal
      RA_CORD=${RAhr}$(echo "scale=7; ${RAmin}/60 + ${RAsec}/3600;" | bc)
      # DECdeg could be negative
      DEC_CORD=${DECdeg}$(echo "scale=5; ${DECmin}/60 + ${DECsec}/3600;" | bc)
  
      echo RA_CORD=$RA_CORD
      echo DEC_CORD=$DEC_CORD


      JOB_SEQ=${SEQ_DIR}/${TARGET}_${JOBNUM}.esl

      #pick exposure sequence
      FileSelect
      EXPOSURE_SEQ=$ESQFILE

      # Header
      cat << _EOF > $JOB_SEQ
<?xml version="1.0" encoding="UTF-8"?>
<SchedulerList version='1.4'>
<Profile>${EQUIP_PROFILE}</Profile>
_EOF

      echo "[${FOCUS_OPT}]"
      #Job   
      cat << _EOF >> $JOB_SEQ
<Job>
<Name>${TARGET}</Name>
<Priority>10</Priority>
<Coordinates>
<J2000RA>${RA_CORD}</J2000RA>
<J2000DE>${DEC_CORD}</J2000DE>
</Coordinates>
<Sequence>${EXPOSURE_SEQ}</Sequence>
<StartupCondition>
<Condition>ASAP</Condition>
</StartupCondition>
<Constraints>
<Constraint value='10'>MinimumAltitude</Constraint>
<Constraint>EnforceTwilight</Constraint>
<Constraint>EnforceArtificialHorizon</Constraint>
</Constraints>
<CompletionCondition>
<Condition>Sequence</Condition>
</CompletionCondition>
<Steps>
<Step>Track</Step>
${FOCUS_OPT}
<Step>Align</Step>
<Step>Guide</Step>
</Steps>
</Job>
_EOF

      # Trailer
      cat << _EOF >> $JOB_SEQ
<ErrorHandlingStrategy value='1'>
<delay>0</delay>
</ErrorHandlingStrategy>
<StartupProcedure>
${STARTUP_PROCEDURE}
</StartupProcedure>
<ShutdownProcedure>
</ShutdownProcedure>
</SchedulerList>
_EOF


      echo
      echo "${magenta}***Summary*****************************************************************"
      echo "${green}Target:  ${white}${TARGET}"
      echo "${green}Converted Coordinates:"
      echo "${green}    RA-  ${white}${RA_CORD}"
      echo "${green}   DEC-  ${white}${DEC_CORD}"
      echo "${green}Exposure Sequenced used:"
      echo "${green}     ${white}${EXPOSURE_SEQ}"
      echo "${green}Job Sequence Created:"
      echo "     ${white}${JOB_SEQ}"
      echo "${magenta}***************************************************************************"
      echo
      echo -n "${yellow}Is this correct Continue "; ANS=$(ckyorn y)
      if [ "$ANS" = "y" ] ; then
          AGAIN="N"
      else
	  AGAIN="Y"
      fi
      echo 
      echo ${reset}

  done  
}

CreateMultiJobSequence() {

   # Sequence Name
   echo -n "${white}Enter Schedule Name: ${yellow}" ; read SCHEDNAME

   JOB_SEQ=${SEQ_DIR}/${SCHEDNAME}_${JOBNUM}.esl

   # Create Sequence Header
    cat << _EOF > $JOB_SEQ
<?xml version="1.0" encoding="UTF-8"?>
<SchedulerList version='1.4'>
<Profile>astro-iEQ45Pro-WO73_int</Profile>
_EOF

  MORE_JOB="Y"
  # while loop
  while [ "$MORE_JOB" = "Y" ] ; do

    # loop to re-edit if necessary
    AGAIN="Y"
    while [ "$AGAIN" = "Y" ] ; do


      # Object Name
      echo -n "${white}Enter Target Name: ${yellow}" ; read TARGET
  
      # RA Coordinates
      echo -n "${white}Enter RA Coordinates (0 42 44.3): ${yellow}" ; read RA

      # DEC Coordinates
      echo -n "${white}Enter DEC Coordinates (41 16 08): ${yellow}" ; read DEC

        echo -n "${yellow}Is the above information correct "; ANS=$(ckyorn y)
        if [ "$ANS" = "y" ] ; then
            AGAIN="N"
        else
            AGAIN="Y"
        fi
    done

        # Select Options, Track, Align, Focus, Guide  (Focus is the only optional step
    echo -n "${white}Do you want to set 'Focus' during sequence steps ${yellow}"; ANS=$(ckyorn n)
    if [ "$ANS" = "n" ] ; then
        FOCUS_OPT=
    else
        FOCUS_OPT="<Step>Focus</Step>"
    fi


    # use awk to split the values
    RAhr=$(echo $RA | awk '{print $1}')
    RAmin=$(echo $RA | awk '{print $2}')
    RAsec=$(echo $RA | awk '{print $3}')

    DECdeg=$(echo $DEC | awk '{print $1}')
    DECmin=$(echo $DEC | awk '{print $2}')
    DECsec=$(echo $DEC | awk '{print $3}')

    # Convert Coordinates to decimal

    RA_CORD=${RAhr}$(echo "scale=7; ${RAmin}/60 + ${RAsec}/3600;" | bc)
    # DECdeg could be negative
    DEC_CORD=${DECdeg}$(echo "scale=5; ${DECmin}/60 + ${DECsec}/3600;" | bc)

    echo RA_CORD=$RA_CORD
    echo DEC_CORD=$DEC_CORD



    #pick exposure sequence
    FileSelect
    EXPOSURE_SEQ=$ESQFILE


    #Job
    cat << _EOF >> $JOB_SEQ
<Job>
<Name>${TARGET}</Name>
<Priority>10</Priority>
<Coordinates>
<J2000RA>${RA_CORD}</J2000RA>
<J2000DE>${DEC_CORD}</J2000DE>
</Coordinates>
<Sequence>${EXPOSURE_SEQ}</Sequence>
<StartupCondition>
<Condition>${START_CONDITION}</Condition>
</StartupCondition>
<Constraints>
<Constraint value='10'>MinimumAltitude</Constraint>
<Constraint>EnforceTwilight</Constraint>
</Constraints>
<CompletionCondition>
<Condition>Sequence</Condition>
</CompletionCondition>
<Steps>
<Step>Track</Step>
${FOCUS_OPT}
<Step>Align</Step>
<Step>Guide</Step>
</Steps>
</Job>
_EOF


    echo
    echo "${magenta}***Summary*****************************************************************"
    echo "${green}Schedule Name:  ${white} ${SCHEDNAME}"
    echo "${green}Target:         ${white} ${TARGET}"
    echo "${green}Converted Coordinates:"
    echo "${green}          RA-  ${white} ${RA_CORD}"
    echo "${green}         DEC-  ${white} ${DEC_CORD}"
    echo "${green}Exposure Sequenced used:"
    echo "               ${white} ${EXPOSURE_SEQ}"
    echo "${green}Job Sequence Created:"
    echo "${white}     ${JOB_SEQ}"
    echo "*${magenta}**************************************************************************"
    echo

    # Another Job?
    echo -n "${yellow}Another Job " ; ANS=$(ckyorn n)
    if [ "$ANS" = "y" ] ; then
        MORE_JOB="Y"
    else
        MORE_JOB="N"

        # Add Observatory Shutdown Procedure
        echo -n "${white}Do you want to add final shutdown procedure ${yellow}"; ANS=$(ckyorn n)
        if [ "$ANS" = "n" ] ; then
            FINAL_SHUTDOWN="N"
        else
            FINAL_SHUTDOWN="Y"
        fi
    fi

    echo ${white}
    echo

  done

    # Trailer
    if [ "$FINAL_SHUTDOWN" = "Y" ] ; then
       cat << _EOF >> $JOB_SEQ
<ErrorHandlingStrategy value='1'>
<delay>0</delay>
</ErrorHandlingStrategy>
<StartupProcedure>
${STARTUP_PROCEDURE}
</StartupProcedure>
<ShutdownProcedure>
<Procedure>WarmCCD</Procedure>
<Procedure>ParkMount</Procedure>
</ShutdownProcedure>
</SchedulerList>
_EOF
  else
     # no shutdown
     cat << _EOF >> $JOB_SEQ
<ErrorHandlingStrategy value='1'>
<delay>0</delay>
</ErrorHandlingStrategy>
<StartupProcedure>
${STARTUP_PROCEDURE}
</StartupProcedure>
<ShutdownProcedure>
</ShutdownProcedure>
</SchedulerList>
_EOF

  fi
}


## main

# select menu

# 1 - Create Exposure Sequence
# 2 - Create Job Sequence (look if multiple for single mosiac)
# 3 - List Exposure Sequences
# 4 - List Job Sequences
# 5 - Change Exposure Sequence
# 6 - Change Job Sequence

if [ ! -d ${SEQ_DIR} ] ; then
  mkdir -p ${SEQ_DIR}
fi

while true
do
   echo "${green}Select Menu Option"

   echo "${white}1 - Create Exposure Sequence"
   echo "2 - Create Single Job Sequence (single job, no ending Condx)"
   echo "3 - Create Multiple Job Sequence (multi job, Ending Condx)"
   echo "4 - List Exposure Sequences"
   echo "5 - List Job Sequences"
   echo "6 - Change Exposure Sequence"
   echo "7 - Change Job Sequence"
   echo "x - Exit"
   echo
   echo -n "${yellow}Enter Selection: ${reset}" ; read SELECTION
   echo

   case $SELECTION in
    1)   # Create the ExposureSeq
	  CreateExposureSeq
          ;;
    2)   # Create Single Job Sequence
          CreateJobSequence 
          ;;
    3)   # Create Multiple Job Sequence
          CreateMultiJobSequence 
          ;;
    4)   # list Exposure Sequences
	  echo "==================================================================================================="  
          ls ${SEQ_DIR}/*.esq
	  echo "==================================================================================================="  
	  echo
          ;;
    5)   # list Job Sequences
	  echo "==================================================================================================="  
          ls ${SEQ_DIR}/*.esl
	  echo "==================================================================================================="  
	  echo
          ;;
    6)   # Change Exposure Sequence
          CreateExposureSeq
          ;;
    7)   # Change Job Sequence
          CreateJobSequence
          ;;
    x)   # Change Job Sequence
          exit 0
          ;;
    *)
          echo "invalid option "
	  ;;
   esac

done


## end

## Notes
## Repeat for 2 runs:
##  <CompletionCondition>
##  <Condition value='2'>Repeat</Condition>
##  </CompletionCondition>

## Repeat until terminated:
##  <CompletionCondition>
##  <Condition>Loop</Condition>
##  </CompletionCondition>

## Shutdown Procedure
##  <ShutdownProcedure>
##  <Procedure>WarmCCD</Procedure>
##  <Procedure value='/home/ekos/Kstars/Scripts/shutdown_obs.sh'>ShutdownScript</Procedure>
##  <Procedure>ParkMount</Procedure>
##  </ShutdownProcedure>

