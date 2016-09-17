#!/bin/bash

parm=$1
eval ">test.txt"
parm="$(echo $parm | sed -e 's/ /\\ /g')"
eval "sed -e 's/[<>!]/ /g' -e 's/DOCTYPE html/ /g' $parm >> test.txt"
leftCount=`cat test.txt | wc -l`
count=0
while read line
do
	count=`expr $count + 1`
	if [[ $line != "/"* ]]; then
		if [[ $line == "" ]]; then
			if [[ $count == 1 ]]; then
				count=0
				leftCount=`expr $leftCount - 1`
			else
				echo "data : "$line
			fi
		else
			if [[ $count == 1 ]]; then
				echo "{\n"$line" : {"
			else
				if [[ $line == *"/"* && $line == *""* ]]; then
					id="$( cut -d '/' -f 1 <<< "$line" | cut -d ' ' -f 1 )"
					otherid="$( cut -d '/' -f 1 <<< "$line")"
					echo "\t\t"$id" : [{"
					if [[ $otherid == ""* ]]; then
						for i in $otherid
						do
							if [[ $i == *"="* ]]; then
								echo "\t\t\t attr : [{"
								property="$( cut -d '=' -f 1 <<< "$i" )"
								value="$( cut -d '=' -f 2 <<< "$i" )"
								if [[ $property != "" ]]; then
									echo "\t\t\t\tProperty : "$property","
								fi
								if [[ $value != "" ]]; then
									if [[ $value == *":"* ]]; then
										echo "\t\t\tvalue : [{"
										property="$( cut -d ':' -f 1 <<< "$value" | sed -e 's/"//g')"
										value="$( cut -d ':' -f 2 <<< "$value" | sed -e 's/"//g')"
										if [[ $property != "" ]]; then
											echo "Property : "$property","
										fi
										if [[ $value != "" ]]; then
											echo "\t\t\t\tvalue : "$value","
											echo "\t\t\t}],"
										fi
									else
										value="$(echo $value | sed -e 's/"//g')"
										echo "\t\t\t\tvalue : "$value","
										echo "\t\t\t}],"
									fi
								fi
							else
								if [[ $id != $i ]]; then
									echo "\t\t\tattr : [{"
									echo "\t\t\t\tdata : "$i
									echo "\t\t\t}],"
								fi
							fi
						done
					fi
					echo "\t\t}],"
				else
					echo "\t"$line" : {"
				fi
			fi
		fi
	else
		if [ $count != $leftCount ]; then
			echo "\t},"
		else
			echo "},\n}"
		fi
	fi
done < test.txt
