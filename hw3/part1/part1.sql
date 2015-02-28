DROP VIEW IF EXISTS q1a, q1b, q1c, q1d, q2, q3, q4, q5, q6, q7;

-- Question 1a
CREATE VIEW q1a(id, amount)
AS
  SELECT C.cmte_id, C.transaction_amt 
  FROM committee_contributions as C
  WHERE C.transaction_amt > 5000
  ;
;

-- Question 1b
CREATE VIEW q1b(id, name, amount)
AS
  SELECT C.cmte_id, C.name, C.transaction_amt 
  FROM committee_contributions as C
  WHERE C.transaction_amt > 5000
  ;
;

-- Question 1c
CREATE VIEW q1c(id, name, avg_amount)
AS
  SELECT C.cmte_id, C.name, avg(C.transaction_amt) as avg_amount 
  FROM committee_contributions as C
  WHERE C.transaction_amt > 5000
  GROUP BY C.name, C.cmte_id
  ;
;

-- Question 1d
CREATE VIEW q1d(id, name, avg_amount)
AS
  SELECT C.cmte_id, C.name, avg(C.transaction_amt)
  FROM committee_contributions as C
  WHERE C.transaction_amt > 5000
  GROUP BY C.name, C.cmte_id
  HAVING avg(C.transaction_amt) > 10000
  ;
;

-- Question 2
-- Find the names of the top 10 (directed) committee pairs that are affiliated
-- with the Democratic Party, who have the highest number of intercommittee 
-- transactions. By directed, we mean (C1 donates to C2) is not the same 
-- (C2 donates to C1).
CREATE VIEW q2(from_name, to_name)
AS
  SELECT C1.name, C2.name
  FROM committees as C1, committees as C2, intercommittee_transactions as I
  WHERE C1.id = I.other_id AND C2.id = I.cmte_id
        AND C1.pty_affiliation = 'DEM' AND C2.pty_affiliation = 'DEM'
  GROUP BY C1.name, C2.name
  ORDER BY COUNT(*) DESC
  LIMIT 10
  ;
;

-- Question 3
-- Find the names of all committees which have not made a contribution to Barack Obama.
CREATE VIEW q3(name)
AS
  SELECT COMALL.name
  FROM committees as COMALL
  WHERE COMALL.id NOT IN 
    ( SELECT DISTINCT COMT.id
      FROM committees as COMT, candidates as CAND, committee_contributions as COBT
      WHERE COMT.id = COBT.cmte_id AND COBT.cand_id = CAND.id AND CAND.name = 'OBAMA, BARACK'
      GROUP BY COMT.id)
  ;
;

-- Question 4.
-- Find the names of candidates have received contributions from more than 1% of all committees.
CREATE VIEW q4 (name)
AS
  WITH cand_cmte (cand_name, cand_id, cmte_id) AS (
    SELECT C.name, T.cand_id, T.cmte_id
    FROM candidates AS C, committee_contributions AS T
    WHERE C.id = T.cand_id
    GROUP BY C.name, T.cand_id, T.cmte_id
  ), count_cmte (name, id, count_num) AS ( 
    SELECT CACM.cand_name, CACM.cand_id, COUNT(*)
    FROM cand_cmte AS CACM
    GROUP BY CACM.cand_name, CACM.cand_id
    HAVING COUNT(*) * 100 > (SELECT COUNT(*) FROM committees)
    ORDER BY CACM.cand_name
  )
  SELECT M.name
  FROM count_cmte AS M
  ;
;

-- Question 5
CREATE VIEW q5 (name, total_pac_donations) AS
  WITH left_join (id, name, amount) as (
    SELECT C.id, C.name, SUM(I2.transaction_amt)
    FROM committees C LEFT OUTER JOIN (
      SELECT * FROM individual_contributions I
      WHERE I.entity_tp = 'ORG'
    ) I2 ON C.id = I2.cmte_id
    GROUP BY C.id, C.name
  )
  SELECT L.name, L.amount
  FROM left_join L
  ;
;

-- Question 6
CREATE VIEW q6 (id) AS
  SELECT DISTINCT C.cand_id
  FROM committee_contributions as C 
  WHERE C.entity_tp = 'PAC' AND cand_id is NOT NULL
  GROUP BY C.cand_id

  INTERSECT

  SELECT DISTINCT D.cand_id
  FROM committee_contributions as D 
  WHERE D.entity_tp = 'CCM' AND cand_id is NOT NULL
  GROUP BY D.cand_id
  ;
;

-- Question 7
CREATE VIEW q7 (cand_name1, cand_name2) AS
  SELECT 1,1 -- replace this line
;
