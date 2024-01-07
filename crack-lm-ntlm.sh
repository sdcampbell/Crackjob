#/bin/bash

if [ -z "$1" ]; then
    echo "No hashfile supplied"
    exit
fi
hashfile=$1
if [ ! -f $hashfile ]; then
   echo "[ERROR] File not exists."
   exit
fi
days=$2
seconds=$(python3 -c "seconds = $days * 86400;print(seconds, end='')")
total_hashes=$(wc -l < "$hashfile")
echo "Total hashes: $total_hashes"
unique_hashes=$(cat $1 | cut -d ':' -f 4 | sort -u | wc -l)
hashcat -w 4 -m 3000 --session crackjob --potfile-path $(pwd)/lmpot ${hashfile} -a 3 -1 ?u?d?s ?1?1?1?1?1?1?1 -i
hashcat -w 4 -m 3000 --session crackjob --potfile-path $(pwd)/lmpot ${hashfile} /usr/share/hashcat/wordlists/super_wordlist
hashcat -m 3000 --session crackjob --potfile-path $(pwd)/lmpotfile ${hashfile} --show | cut -d ':' -f 2 | grep . > lm.txt
hashcat -m 1000 --session crackjob -w 4 --potfile-path $(pwd)/ntpotfile -r /usr/share/hashcat/rules/toggles-lm-ntlm.rule ${hashfile} lm.txt
hashcat -m 1000 --session crackjob -w 4 --potfile-path $(pwd)/ntpotfile ${hashfile} /usr/share/hashcat/wordlists/super_wordlist
hashcat -m 1000 --session crackjob -w 4 --potfile-path $(pwd)/ntpotfile -r /usr/share/hashcat/rules/OneRuleToRuleThemAll.rule ${hashfile} /usr/share/hashcat/wordlists/super_wordlist
#hashcat -m 1000 -w 4 --potfile-path $(pwd)/ntpotfile -r /usr/share/hashcat/rules/OneRuleToRuleThemAll.rule ${hashfile} /usr/share/hashcat/wordlists/super_wordlist --show --user > cracked.txt
hashcat -m 1000 --session crackjob -a 3 --potfile-path $(pwd)/ntpotfile --increment --increment-min 1 --increment-max 8 --runtime=$seconds ${hashfile} ?a?a?a?a?a?a?a?a
hashcat -m 1000 --session crackjob -a 3 --potfile-path $(pwd)/ntpotfile --increment --increment-min 1 --increment-max 8 ${hashfile} ?a?a?a?a?a?a?a?a --show --user > cracked.txt

cracked_hashes=$(cat cracked.txt|wc -l)
echo ""
echo "Total hashes: $total_hashes"
echo "Unique hashes: $unique_hashes"
echo "Number of accounts with LM enabled: $(cat ${hashfile} | grep -v aad3b435b51404eeaad3b435b51404ee | wc -l)"

cat $1 | grep -v '\$' | cut -d ':' -f 1,4 | sed '/:$/!s/$/:/' > junk1

cat cracked.txt >> junk1

tac junk1 | sort -k1,1 -r -u -t: > pypipal.txt

rm junk1
