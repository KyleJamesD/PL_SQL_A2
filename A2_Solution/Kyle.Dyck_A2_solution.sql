SET ECHO ON 
SPOOL C:/cprg307spool/Group7_A2_spool_kyledyck.txt


Set serveroutput on
set linesize 500;
set pagesize 500;


Select * 
from new_transactions;

select * 
from transaction_history;

select * 
from transaction_detail;

select *
from account;


DECLARE --1

CURSOR c_newtransaction IS 
Select *
FROM new_transactions;

--Hard coded Values
v_credit account_type.default_trans_type%TYPE := 'C';
v_debit account_type.default_trans_type%TYPE := 'D';

--variables
v_outer_transaction_no              new_transactions.transaction_no%TYPE;
v_outer_transaction_date                new_transactions.transaction_date%TYPE;
v_outer_description             new_transactions.description%TYPE;
v_outer_account_no              new_transactions.account_no%TYPE;
v_outer_transaction_type                new_transactions.transaction_type%TYPE;
v_outer_transaction_amount              new_transactions.transaction_amount%TYPE;

--true or false records for insertion into transaction history
v_is_transaction_history_there boolean := TRUE;
v_transaction_count                 NUMBER;



--Variable for holding account type code
v_account_type_code_is          account.account_type_code%TYPE;
v_DEBIT_OR_CREDIT      account.account_type_code%TYPE;

--variables for printing to see the action
v_account_balance     account.account_balance%TYPE;

-- Variable to store the count of transactions
BEGIN -- 1


For c_row in c_newtransaction LOOP --1
Begin --2
--Assign the values
      v_outer_transaction_no := c_row.transaction_no;
      v_outer_transaction_date := c_row.transaction_date;
      v_outer_description := c_row.description;
      v_outer_account_no := c_row.account_no;
      v_outer_transaction_type := c_row.transaction_type;
      v_outer_transaction_amount := c_row.transaction_amount;

-- loop to find if transaction_no is already in transaction history if so then DONT INSERT

        SELECT COUNT(*)
      INTO v_transaction_count
      FROM transaction_history
      WHERE transaction_no = v_outer_transaction_no;

      -- Set the BOOLEAN flag based on the count
      v_is_transaction_history_there := (v_transaction_count > 0);

      IF NOT v_is_transaction_history_there THEN
        -- If there is no row in table, insert into transaction_history
        INSERT INTO transaction_history (transaction_no, transaction_date, description)
        VALUES (v_outer_transaction_no, v_outer_transaction_date, v_outer_description);
        COMMIT; -- Ensure the parent row is committed
      END IF;



       INSERT INTO transaction_detail (account_no,transaction_no,transaction_type,transaction_amount)
       VALUES (v_outer_account_no,v_outer_transaction_no,v_outer_transaction_type,v_outer_transaction_amount);


        -- find the account type code and convert to Credit or Debit 
        --and set variable to the account# we are working on
        -- and set the variable for the account balance for printing
        FOR L_account_type_code IN (SELECT account_no,account_type_code,account_balance FROM account) LOOP
              IF v_outer_account_no = L_account_type_code.account_no THEN
                v_account_type_code_is := L_account_type_code.account_type_code;
                v_account_balance := L_account_type_code.account_balance;
                EXIT;
              END IF;
            END LOOP;



        v_DEBIT_OR_CREDIT := CASE
                                      WHEN v_account_type_code_is = 'A' THEN 'D'
                                      WHEN v_account_type_code_is = 'L' THEN 'C'
                                      WHEN v_account_type_code_is = 'EX' THEN 'D'
                                      WHEN v_account_type_code_is = 'RE' THEN 'C'
                                      WHEN v_account_type_code_is = 'OE' THEN 'C'
                                      END;
            


        --sloppy could be reduced with else statements
        IF v_outer_transaction_type = 'D' AND v_DEBIT_OR_CREDIT = 'D' THEN
        DBMS_OUTPUT.PUT_LINE('account Balance for account:' || v_outer_account_no || ' before update D_NT+D_A:' ||v_account_balance);
         DBMS_OUTPUT.PUT_LINE('Amount to Add:' || v_outer_transaction_amount);
          UPDATE account
          set account_balance = account_balance + v_outer_transaction_amount
          WHERE account_no = v_outer_account_no;
                --requery the variabe to update to new account balance
              SELECT account_balance INTO v_account_balance
              FROM account
              WHERE account_no = v_outer_account_no;
              DBMS_OUTPUT.PUT_LINE('Account balance for account:' || v_outer_account_no || ' after update D_NT+D_A: ' || v_account_balance);
        END IF;  

        IF v_outer_transaction_type = 'C' AND v_DEBIT_OR_CREDIT = 'D' THEN
        DBMS_OUTPUT.PUT_LINE('account Balance for account:' || v_outer_account_no || ' before update C_NT-D_A:' ||v_account_balance);
        DBMS_OUTPUT.PUT_LINE('Amount to subtract:' || v_outer_transaction_amount);
        UPDATE account
          set account_balance = account_balance - v_outer_transaction_amount
          WHERE account_no = v_outer_account_no;
                --requery the variabe to update to new account balance
              SELECT account_balance INTO v_account_balance
              FROM account
              WHERE account_no = v_outer_account_no;
              DBMS_OUTPUT.PUT_LINE('Account balance for account:' || v_outer_account_no || ' after update C_NT-D_A: ' || v_account_balance);
          END IF;

        IF v_outer_transaction_type = 'C' AND v_DEBIT_OR_CREDIT = 'C' THEN
        DBMS_OUTPUT.PUT_LINE('account Balance for account:' || v_outer_account_no || ' before update C_NT+C_A:' ||v_account_balance);
        DBMS_OUTPUT.PUT_LINE('Amount to Add:' || v_outer_transaction_amount);
        UPDATE account
          set account_balance = account_balance + v_outer_transaction_amount
          WHERE account_no = v_outer_account_no;
                --requery the variabe to update to new account balance
              SELECT account_balance INTO v_account_balance
              FROM account
              WHERE account_no = v_outer_account_no;
              DBMS_OUTPUT.PUT_LINE('Account balance for account:' || v_outer_account_no || ' after update C_NT+C_A: ' || v_account_balance);
          END IF;

        IF v_outer_transaction_type = 'D' AND v_DEBIT_OR_CREDIT = 'C' THEN
        DBMS_OUTPUT.PUT_LINE('account Balance for account:' || v_outer_account_no || ' before update D_NT-C_A:' ||v_account_balance);
        DBMS_OUTPUT.PUT_LINE('Amount to subtract:' || v_outer_transaction_amount);
        UPDATE account
          set account_balance = account_balance - v_outer_transaction_amount
          WHERE account_no = v_outer_account_no;
              --requery the variabe to update to new account balance
              SELECT account_balance INTO v_account_balance
              FROM account
              WHERE account_no = v_outer_account_no;
              DBMS_OUTPUT.PUT_LINE('Account balance for account:' || v_outer_account_no || ' after update D_NT-C_A: ' || v_account_balance);
          END IF;
-- DELETE MUT GO AT END AFTER other columns are added
         DELETE FROM new_transactions
         WHERE 
         transaction_no = v_outer_transaction_no AND
         account_no = v_outer_account_no AND
         transaction_type = v_outer_transaction_type AND
         transaction_amount = v_outer_transaction_amount;



          EXCEPTION -- put exception here to ROLLBACK CHANGES IF NOT SUCCESSFUL
          WHEN OTHERS THEN
          DBMS_OUTPUT.PUT_LINE('An error occurred: ' || SQLERRM);
            ROLLBACK;



        
        


END; --2
COMMIT;


END LOOP; --1
--EXCEPTION--1
END; -- 1
/


Select * 
from new_transactions;

select * 
from transaction_history;

select * 
from transaction_detail;

select *
from account;







spool off