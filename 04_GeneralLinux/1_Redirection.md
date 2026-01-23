# INFO 1:
* stdin    => Keyboard   => ReadOnly.
* stdout   => Terminal   => WriteOnly.
* stderr   => Terminal   => WriteOnly.
* filename => None       => R/W or WR.

/dev/null/ => Dustbin.

# INFO 2:
---
  - op >   file        => OP into file Re-write                | No-Display 
  - op 2>  file        => ERR into file                        | OP-display 
  - op &>  file        => OP + ERR into File                   | NO-Display
  - op &>> file        => OP + ERR at billow File              | NO-Display
---
  - op >>  file        => OP into billow original file         | NO-Display
---
  - op 2>/dev/null     => ERR into Dustbin                     | OP-Display
  - op >> file 2>&1    => OP + ERR into File Proper management | NO-Display 
  > the above 1 is important. 
---

eg 

```bash 
date > ./1_timestamp
tail -n 100 /var/log/dmesg > ./2_last-100-bootMessages
cat file1 file2 file3 file4 > ./3_all-4-filesIn-one
ls -a > ./4_list-all
echo "|-------------- New line of informaiton --------------|" >> ./1_timestamp 
diff 

```


