#!/bin/bash
clear
RUN_YEAR="2016"
RUN_MONTH="Apr"
RUN_MONTH_NUMBER="04"
INSTANCE_COUNT=`ls ./*.txt | wc -l`
TIME_TOTAL="0"

for instance in `ls ./*.txt`; do

	INSTANCE_NAME=`echo $instance | awk -F. '{ print $2 }' | sed -e 's/\///g'`
	START_DAY=`grep -m1 $RUN_MONTH $instance | awk '{ print $3 }'`
	START_DAY=`echo $RUN_YEAR$RUN_MONTH_NUMBER$START_DAY`
	START_TIME=`grep -m1 $RUN_MONTH $instance | awk '{ print $4 }' | awk -F: '{ print $1 $2 }'`
	START_SECONDS=`date --date "$START_DAY $START_TIME" +%s`
	END_DAY=`grep -m2 $RUN_MONTH $instance | awk '{ print $3 }' | tail -n1`
	END_DAY=`echo $RUN_YEAR$RUN_MONTH_NUMBER$END_DAY`
	END_TIME=`grep -m2 $RUN_MONTH $instance | tail -n1 | awk '{ print $4 }' | awk -F: '{ print $1 $2 }'`
	END_SECONDS=`date --date "$END_DAY $END_TIME" +%s`
	TIME_DIFF_SECONDS=`echo $(( $END_SECONDS - $START_SECONDS ))`
	TIME_DIFF_MINUTES=`echo "$TIME_DIFF_SECONDS / 60" | bc`
	TIME_DIFF_HOURS=`echo "scale=2; $TIME_DIFF_MINUTES / 60" | bc`
	TIME_TOTAL=`echo "scale=2; $TIME_TOTAL + $TIME_DIFF_HOURS" | bc`

	echo ""
	echo "--------------------------------"
	echo "INSTANCE NAME:	$INSTANCE_NAME"
	echo ""
	echo "START DAY:	$START_DAY"
	echo "START TIME:	$START_TIME"
	echo "START SECONDS:	$START_SECONDS Seconds"
	echo ""
	echo "END DAY:	$END_DAY"
	echo "END TIME:	$END_TIME"
	echo "END SECONDS:	$END_SECONDS Seconds"
	echo ""
	echo "RUN SECONDS:	$TIME_DIFF_SECONDS Seconds"
	echo "RUN MINUTES:	$TIME_DIFF_MINUTES Minutes"
	echo "RUN HOURS:	$TIME_DIFF_HOURS Hours"
	echo "--------------------------------"

done

AVG_RUN_TIME=`echo "scale=2; $TIME_TOTAL / $INSTANCE_COUNT" | bc`
UNITS_PER_HOUR=`echo "scale=2; $INSTANCE_COUNT / $AVG_RUN_TIME" | bc`
echo ""
echo "--------------------------------"
echo "INSTANCE COUNT:	$INSTANCE_COUNT"
echo "TIME TOTAL:	$TIME_TOTAL Hours"
echo "AVG RUN TIME:	$AVG_RUN_TIME Hours"
echo "UNITS PER HOUR:	$UNITS_PER_HOUR"
