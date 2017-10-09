today=$(date "+%Y%m%d")

      mpstat -P ALL >> $TMPDIR/mp_snapshot_${today}.txt 
      echo "  ################################################################# " >> $TMPDIR/mp_snapshot_${today}.txt
