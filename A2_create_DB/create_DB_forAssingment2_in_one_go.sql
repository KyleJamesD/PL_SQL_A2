DROP TABLE payroll_processing;
DROP TABLE payroll_load;
DROP TABLE transaction_detail;
DROP TABLE transaction_history;
DROP TABLE account;
DROP TABLE account_type;
DROP TABLE new_transactions;
DROP TABLE wkis_error_log;

DROP SEQUENCE wkis_seq;

CREATE SEQUENCE wkis_seq
  START WITH 1
  INCREMENT BY 2;

CREATE TABLE account_type
(account_type_code  	VARCHAR2(2),
 default_trans_type 	CHAR(1),
 description 	    	VARCHAR2(100)
);

CREATE TABLE account
(account_no		NUMBER,
 account_name		VARCHAR2(30),
 account_type_code	VARCHAR2(2),
 account_balance	NUMBER
);

CREATE TABLE transaction_detail
(account_no		NUMBER,
 transaction_no		NUMBER,
 transaction_type	CHAR(1),
 transaction_amount	NUMBER
);

CREATE TABLE transaction_history
(transaction_no		NUMBER,
 transaction_date	DATE,
 description		VARCHAR2(100)
);

CREATE TABLE payroll_load
(payroll_date		DATE,
 employee_id		VARCHAR2(9),
 amount			NUMBER,
 status			CHAR(1)
);

CREATE TABLE payroll_processing
(month_end		CHAR(1),
 payroll		CHAR(1)
);


CREATE TABLE new_transactions
(transaction_no		NUMBER,
 transaction_date	DATE,
 description		VARCHAR2(100),
 account_no		NUMBER,
 transaction_type	CHAR(1),
 transaction_amount	NUMBER
);

CREATE TABLE wkis_error_log AS
  SELECT *
    FROM transaction_history;

ALTER TABLE wkis_error_log
  ADD error_msg VARCHAR2(200);




ALTER TABLE account_type
  ADD CONSTRAINT pk_wkis_account_type PRIMARY KEY(account_type_code)
  ADD CONSTRAINT ck_trans_type CHECK (default_trans_type IN ('D', 'C'));

ALTER TABLE account
  ADD CONSTRAINT pk_wkis_account PRIMARY KEY(account_no)
  ADD CONSTRAINT fk_account_to_at FOREIGN KEY(account_type_code)
      REFERENCES account_type (account_type_code);

ALTER TABLE transaction_history
  ADD CONSTRAINT pk_transaction_history PRIMARY KEY(transaction_no);

ALTER TABLE transaction_detail
  ADD CONSTRAINT pk_transaction_detail PRIMARY KEY(account_no, transaction_no)
  ADD CONSTRAINT ck_transaction_type CHECK (transaction_type IN ('D', 'C'))
  ADD CONSTRAINT fk_td_to_account FOREIGN KEY(account_no)
      REFERENCES account(account_no)
  ADD CONSTRAINT fk_td_to_transaction FOREIGN KEY(transaction_no)
      REFERENCES transaction_history(transaction_no);


-- Inserts into ACCOUNT_TYPE

INSERT INTO account_type
VALUES
('A', 'D', 'Asset');

INSERT INTO account_type
VALUES
('L', 'C', 'Liability');

INSERT INTO account_type
VALUES
('EX', 'D', 'Expense');

INSERT INTO account_type
VALUES
('RE', 'C', 'Revenue');

INSERT INTO account_type
VALUES
('OE', 'C', 'Owners Equity');

COMMIT;

-- Inserts into ACCOUNT
--	Assets are in the 1000 range
--	Liabilities are in the 2000 range
--	Revenues are in the 3000 range
--	Expenses are in the 4000 range
--	Owners Equity is account 5555

INSERT INTO account
VALUES
(1250, 'Cash', 'A', 0);

INSERT INTO account
VALUES
(1150, 'Accounts Receivable', 'A', 0);

INSERT INTO account
VALUES
(1850, 'Investment', 'A', 0);

INSERT INTO account
VALUES
(1930, 'Building', 'A', 0);

INSERT INTO account
VALUES
(2050, 'Accounts Payable', 'L', 0);

INSERT INTO account
VALUES
(2580, 'Mortgage', 'L', 0);

INSERT INTO account
VALUES
(4006, 'Mortgage Expense', 'EX', 0);

INSERT INTO account
VALUES
(4045, 'Payroll Expense', 'EX', 0);

INSERT INTO account
VALUES
(4078, 'Utilities Expense', 'EX', 0);

INSERT INTO account
VALUES
(3058, 'Service Revenue', 'RE', 0);

INSERT INTO account
VALUES
(3073, 'Royalty Revenue', 'RE', 0);

INSERT INTO account
VALUES
(5555, 'Owners Equity', 'OE', 0);

COMMIT;

-- Inserts into PAYROLL_PROCESSING

INSERT INTO payroll_processing
VALUES
('Y', 'Y');

COMMIT;


-- Inserts into NEW_TRANSACTIONS
--transaction 1
INSERT INTO new_transactions
VALUES
(wkis_seq.NEXTVAL, TRUNC(SYSDATE), 'Payment for services rendered', 1250, 'D', 30000);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Payment for services rendered', 3058, 'C', 30000);

--transaction 2
INSERT INTO new_transactions
VALUES
(wkis_seq.NEXTVAL, TRUNC(SYSDATE), 'Investment purchased', 1850, 'D', 30000);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Investment purchased', 1250, 'C', 30000);

--transaction 3
INSERT INTO new_transactions
VALUES
(wkis_seq.NEXTVAL, TRUNC(SYSDATE), 'Royalty revenue', 1250, 'D', 10000);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Royalty revenue', 3073, 'C', 10000);

--transaction 4
INSERT INTO new_transactions
VALUES
(wkis_seq.NEXTVAL, TRUNC(SYSDATE), 'New property purchased', 1930, 'D', 129400);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'New property purchased', 2580, 'C', 120000);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'New property purchased', 1250, 'C', 9400);

--transaction 5
INSERT INTO new_transactions
VALUES
(wkis_seq.NEXTVAL, TRUNC(SYSDATE), 'Invoiced for services rendered', 1150, 'D', 1400);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Invoiced for services rendered', 3058, 'C', 1400);

--transaction 6
INSERT INTO new_transactions
VALUES
(wkis_seq.NEXTVAL, TRUNC(SYSDATE), 'Payroll processed', 4045, 'D', 50000);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Payroll processed', 2050, 'C', 50000);

--transaction 7
INSERT INTO new_transactions
VALUES
(wkis_seq.NEXTVAL, TRUNC(SYSDATE), 'Monthend roll to owners equity', 3058, 'D', 31400);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Monthend roll to owners equity', 3073, 'D', 10000);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Monthend roll to owners equity', 5555, 'D', 8600);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Monthend roll to owners equity', 4045, 'C', 50000);

--transaction 8
INSERT INTO new_transactions
VALUES
(wkis_seq.NEXTVAL, TRUNC(SYSDATE), 'Payment for services rendered', 1250, 'D', 40000);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Payment for services rendered', 3058, 'C', 40000);

--transaction 9
INSERT INTO new_transactions
VALUES
(wkis_seq.NEXTVAL, TRUNC(SYSDATE), 'Mortgage payment', 4006, 'D', 15000);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Mortgage payment', 1250, 'C', 15000);

--transaction 10
INSERT INTO new_transactions
VALUES
(wkis_seq.NEXTVAL, TRUNC(SYSDATE), 'Monthend roll to owners equity', 3058, 'D', 40000);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Monthend roll to owners equity', 4006, 'C', 15000);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Monthend roll to owners equity', 5555, 'C', 25000);

--transaction 11
INSERT INTO new_transactions
VALUES
(wkis_seq.NEXTVAL, TRUNC(SYSDATE), 'Payroll processed', 4045, 'D', 5000);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Payroll processed', 2050, 'C', 5000);

--transaction 12
INSERT INTO new_transactions
VALUES
(wkis_seq.NEXTVAL, TRUNC(SYSDATE), 'Payroll paid', 2050, 'D', 10000);

INSERT INTO new_transactions
VALUES
(wkis_seq.CURRVAL, TRUNC(SYSDATE), 'Payroll paid', 1250, 'C', 10000);



COMMIT;

