# itns-trade-data
trade.sh will provide an estimated overview of selling and buyback trading result.
The assumption is that you have an X amount of itns coin and will sell them for Y price and buy them back for Z price.

Making this operation will produce a value difference, all differencies are calculated by the script

trade.sh itns sellprice buybackprice  
itns - is the amount of coins you want to sell and buyback    
sellprice - the price you sell itns for, expressed in satoshi or BTC  
buybackprice - the price you will buy itns back, expressed in satoshi or BTC  
Examples:  
Price expressed in satoshi  
trade.sh 1000 60 50  
Price expressed in BTC  
trade.sh 1000 0.00000060 0.00000050  

```
user@localhost:~$ ./trade.sh 1000 60 55                                   
Initial state
Initial ITNS amount: 1000
Initial BTC value: 0.00055000

Sell
ITNS sold: 1000
Price: 0.00000060
BTC pre-fee: 0.00060000
BTC fee: 0.00000090
BTC income: 0.00059910
USD income: 4.78194431

Buy-Back
BTC: 0.00059910 to buy ITNS
Price: 0.00000055
ITNS pre-fee: 1089.27272727
ITNS fee: 1.63390909
ITNS income: 1087.63881818
USD income: 4.40276194

Result
ITNS earned: 87.63881818
BTC earned: 0.00010258
USD earned: 0.81880752

```
