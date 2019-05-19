#!/bin/bash
# This scrip will create a wordlist (dictionary) with Israeli phone numbers.
# Script usage:
# sudo phones2john.sh
#
# Writing the List.External in /etc/john/john.local.conf

while true
do
  # (1) prompt user, and read command line argument
  printf "WARNING...\nThis script will REWRITE your current /etc/john/john.local.conf file\nMake a backup or change script on line 30\n"
  read -p "Got any phone prefix for me...? " answer ;

  # (2) handle the input we were given
  case $answer in
   [yY]* ) read -p "What is the prefix? " PREFIX ;
           while read -n 1 c; do PREARR+=($c); done  <<< "$PREFIX" ;
           b=$(( ${#PREARR[@]} ));
           printf "b equel = $b \n";
           i=9;
           printf "i befor loop = $i \n\n"
           for x in "${PREARR[@]}" ;
           do
               if [[ (( $i > $b )) ]]; then
                 PREARR+="X"
                 printf "PREARR in loop = ${PREARR[$x]}\n\n";
                 (( i-- ))
               fi
               printf "i in loop = $i\n\n"
               (( i-- ))
               if [[ (( $i < $b )) ]]; then break; fi
           done
           for x in "${PREARR[@]}"; do printf "${PREARR[$x]}\n"; done
           if [ "${PREARR[0]}" != "0" ]; then
              printf "\nPrefix must start with 0-digit\n" ;
              exit;
           fi
           printf "Okay, I got your prefix ($PREFIX).\n\n" ;
# C CODE HERE
           cat <<EOF > /etc/john/john.local.conf
[List.External:Filter_$PREFIX]
.include [List.External_base:Sequence]
// The folowing function will modify the generate() function to only generate 10 digit numbers (minlength == maxlength).
void init()
{
        from = '0';
        to = '9';
        minlength = 10;
        maxlength = 10;
        inc = 1;
        // For copied external modes, no further changes should be required
        // in the statements following this comment

        length = minlength;
        first = from;

        if (from <= to) {
                maxlength = to - from + 1;
                direction = 1;
        } else {
                // We have to create sequences which decrement the previous character
                maxlength = from - to + 1;
                direction = -1;
        }
}
void filter()
{
        int prelength, i, c, prechar[10];
        prelength = ${#PREARR[@]};
        i = 0;
        prechar[0] = ${PREARR[0]};
        prechar[1] = ${PREARR[1]};
        prechar[2] = ${PREARR[2]};
        prechar[3] = ${PREARR[3]};
        prechar[4] = ${PREARR[4]};
        prechar[5] = ${PREARR[5]};
        prechar[6] = ${PREARR[6]};
        prechar[7] = ${PREARR[7]};
        prechar[8] = ${PREARR[8]};
        prechar[9] = ${PREARR[9]};

        while (c = word[i++]) {
          while (word[i] != prechar[i]) {
//           if ((word[0] != '${PREARR[0]}') || (word[1] != '${PREARR[1]}') || (word[2] != '${PREARR[2]}')) {
                word = 0; return;
//           }
          }
           if (c < '0' || c > '9' || i > 10) {
                word = 0; return;
           }
        }
}

# Ray: Put this Incremental in /etc/john/john.local.conf
[Incremental:Phone]
File = \$JOHN/digits.chr
MinLen = 10
MaxLen = 10
CharCount = 10
EOF
           printf "Configuration of /etc/john/john.local.conf is done.\n\n"
           printf "Generate now $PREFIX dictionary.lst with John the ripper?\n"
           read -p "This might take awhile... (Y/N) " answer ;
           case $answer in
            [yY]* ) john --incremental=Phone --external=Filter_$PREFIX --stdout | uniq -s 3 -u > wordlist_$PREFIX\.lst
                    printf "\nThe file wordlist_$PREFIX\.lst has been generated to current directory\n"
            ;;
            [nN]* ) exit;;
            * )     printf "\nNo it is...";;
           esac
#           break;;
           ;;

   [nN]* ) exit;;

   * )     printf "\nDude, just enter Y or N, please.";;
  esac
done


