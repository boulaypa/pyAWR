script=unindexed_foreign_keys.sql
target=DOMUTX6
schema=ESBBWPX1

for sche in EPSX1 CCMIAU2X1 CAMHARX1 CAMCARX1 CAMDESX1 RPSGRAX1 MAEX1 SIMANAX1 SIMCODX1 SIMODWX1 SIMODMX1 SIMRAFX1 SIMAPP3X1 SIMAPP1X1 SIMESSTDX1 SIMHSSX1 SIMPLSYSX1 SIMAPP2X1 SIMCALCX1 SIMEASX1 RPSX1 LIGX1 ICEX1 PEDX1 OKOX1 ESBHWKX1 ESBBWPX1 ESBTIBX1 GSMX1 NSIX1 CMIX1 GEDBAGX1 CVTX1 GSPSIDX1 SPFX1 CMNAMXX1 CMNBDSX1 CMNBPMX1
do
    gen_missing_foreign_keys.py --target $target --sql $script --schema $sche 
done
