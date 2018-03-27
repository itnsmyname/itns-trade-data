#!/bin/bash
#set -x

usage ()
{
echo "Usage:
$0 itns sellprice buybackprice

itns - is the amount of coins you want to sell and buyback
sellprice - the price you sell itns for, expressed in satoshi or BTC
buybackprice - the price you will buy itns back, expressed in satoshi or BTC

Examples:
Price expressed in satoshi
$0 1000 60 50

Price expressed in BTC
$0 1000 0.00000060 0.00000050
"
exit 1
}

trimit ()
{
  if [[ -z $2 ]] 
  then
    digit=8
  else 
    digit=$2
  fi

  if [[ $# -eq 0 ]]
  then
    input=`cat /dev/stdin`
  else
    input=$*
  fi

  if [[ $input =~ [.] ]]
  then
    echo "$(echo $input | cut -d "." -f 1).$(echo $input | cut -d "." -f 2 | cut -c 1-${digit})" 
  else
    echo $input
  fi
}

calc ()
{
  if [[ $# -eq 0 ]] 
  then
    input=`cat /dev/stdin`
  else
    input=$*
  fi

  echo "scale =4 ; $input" | bc -l | sed 's/\./0\./g' | sed 's/[0]*$//g'
}

cc ()
{
  if [[ $# -eq 0 ]]; then
      echo "Usage is cc amount (coin) where coin is optional";
      return 1;
  fi;
  amount="$1";
  coin="$2";
  if [[ -z $coin ]]; then
      if [[ $1 < 1 ]]; then
          coin="btc";
      else
          coin="itns";
      fi;
  fi;
  echo ${coin^^}: $1;
  echo USD: `curl -s "https://coinbin.org/$coin/$1" | grep usd | cut -d ":" -f 2 | sed s/^\ //g`
}

satoshi () 
{
  if [[ $# -eq 0 ]]
  then
    input=`cat /dev/stdin`
  else
    input=$*
  fi


  if [[ $input == 0* ]]
  then
    echo "$input"
  else
    if [[ ${#input} -gt 8 ]]
    then
      echo "Satoschi cannot contain more than 8 decimals"
      exit 10
    fi
  neededzeros=$(( 8 - ${#input}))
  zeros=""
  for i in `seq $neededzeros` 
  do 
    zeros+=0
  done
  echo "0.${zeros}${input}"
  fi
}

tousd () 
{
  if [[ $1 =~ ^- ]] 
  then 
    neg=0
  else
    neg=1
  fi

  output=`cc $(echo $1 | tr -d '-') | grep USD | cut -d ":" -f 2 | tr -d " "`

  if [[ $neg == 0 ]]
  then
    echo "-$output"
  else
    echo "$output"
  fi
}

#enable alias expansion
#shopt -s expand_aliases
#alias calc=' bc -l |  sed 's/^\./0\./g' '

if [[ $1 == "-h" ]] || [[ $# -lt 3 ]]
then
  usage
fi

preitns=$1
sellprice=$(satoshi $2)
buyprice=$(satoshi $3)
  
#initial state and values
preitnsv=`cc $preitns`
prebtc=`echo "$preitns * $buyprice" | bc -l | sed -e 's/^\./0\./g' -e 's/^-\./-0\./g'`

#sell
tbtc=`echo "$preitns * $sellprice" | bc -l | sed -e 's/^\./0\./g' -e 's/^-\./-0\./g'`
sellfee=`echo "0.0015 * $tbtc" | bc -l | sed -e 's/^\./0\./g' -e 's/^-\./-0\./g'`
btc=`echo "$tbtc - $sellfee" | bc -l | sed -e 's/^\./0\./g' -e 's/^-\./-0\./g'`

#buyback
titns=`echo "$btc / $buyprice" | bc -l | sed -e 's/^\./0\./g' -e 's/^-\./-0\./g'`
buyfee=`echo "0.0015 * $titns" | bc -l | sed -e 's/^\./0\./g' -e 's/^-\./-0\./g'`
itns=`echo "$titns - $buyfee" | bc -l | sed -e 's/^\./0\./g' -e 's/^-\./-0\./g'`

#final state and values
postitnsv=`cc $itns`
postbtc=`echo "$itns * $sellprice" | bc -l | sed -e 's/^\./0\./g' -e 's/^-\./-0\./g'`

#earnings
btcearned=`echo "$postbtc - $prebtc" | bc -l | sed -e 's/^\./0\./g' -e 's/^-\./-0\./g'`
usdearned=`tousd $btcearned`

echo "Initial state"
echo "Initial ITNS amount: $(trimit $preitns)"
echo "Initial BTC value: $(trimit $prebtc)"
echo
echo "Sell"
echo "ITNS sold: $(trimit $preitns)"
echo "Price: $sellprice"
echo "BTC pre-fee: $(trimit  $tbtc)"
echo "BTC fee: $(trimit $sellfee)"
echo "BTC income: $(trimit $btc)"
echo "USD income: $(tousd $btc | trimit)"
echo 
echo "Buy-Back"
echo "BTC: $(trimit $btc) to buy ITNS"
echo "Price: $buyprice"
echo "ITNS pre-fee: $(trimit $titns)"
echo "ITNS fee: $(trimit $buyfee)"
echo "ITNS income: $(trimit $itns)"
echo "USD income: $(tousd $itns | trimit)"
echo
echo "Result"
echo "ITNS earned: `echo "$itns - $preitns" | bc -l | sed -e 's/^\./0\./g' -e 's/^-\./-0\./g' | trimit`"
echo "BTC earned: $(trimit $btcearned)"
echo "USD earned: $(trimit $usdearned)"
