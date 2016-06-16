set feedback off
SET TERMOUT ON
SET ECHO OFF
set ver off
SET SERVEROUTPUT ON
SET PAGESIZE 15000
SET LINESIZE 100

connect MAGICASH5/NCTMAGICASH5@PC

ACCEPT DATA_BEGIN PROMPT 'Enter DATA_BEGIN 01/05/2016 : ' DEFAULT 01/05/2016
ACCEPT DATA_END PROMPT 'Enter DATA_END 31/12/2020 : ' DEFAULT 31/12/2020

SPOOL EXP_trz.csv

BEGIN
  DBMS_OUTPUT.ENABLE(1500000);
  dbms_output.put_line('" ";" ";"DATA_BEGIN: &DATA_BEGIN";"DATA_END: &DATA_END"');
END;
/

BEGIN
  DBMS_OUTPUT.ENABLE(1500000);
    dbms_output.put_line('"ID_CLIENT";"CLIENT_DESCRIPTION";"SUMMA_U_KOGO_ZAPRAVILIS";"SUMMA_KTO_ZAPRAVILSA";"OPLATA"');
END;
/

alter session set NLS_NUMERIC_CHARACTERS=', ';
DECLARE 
CURSOR OTK is


SELECT privazka_k_gruppe.id_klienta as "ID_CLIENTA",
       nazvanie_firmy.name as "NAME",
       NVL((TABLE_PRODUCT.SUMMA_SO_SKIDKOI * -1), 0) as "U_KOGO_ZAPRAVILIS",
       0 as "KTO_ZAPRAVILSA",
       NVL((TABLE_PAYMENT.PAYMENT), 0) as "OPLATA"
  FROM (SELECT TABLE_SUMMY_PO_VIDAM.ID_FIRMY as "ID_FIRMY",
               TABLE_SUMMY_PO_VIDAM.NAME_FIRMY as "NAME_FIRMY",
               SUM(TABLE_SUMMY_PO_VIDAM.SUMMA_SO_SKIDKOI) as "SUMMA_SO_SKIDKOI"
          FROM (SELECT
                --TABLE_SUMMY.POS_NUMBER,
                 TABLE_SUMMY.ID_USLUGI as "ID_USLUGI",
                 TABLE_SUMMY.SUMMA as "SUMMA",
                 TABLE_TARIF.TARIF as "TARIF",
                 ROUND(TABLE_SUMMY.SUMMA * (100 - TABLE_TARIF.TARIF) / 100, 2) as "SUMMA_SO_SKIDKOI",
                 TABLE_MAIN_TERMINAL.ID_FIRMY as "ID_FIRMY",
                 TABLE_MAIN_TERMINAL.NAME_FIRMY as "NAME_FIRMY"
                  FROM ( /*(3)����� ���� ���������� �� ���������� �� (1)�(2)*/
                        SELECT trzall.TERMINAL as "POS_NUMBER",
                                trzall.ID_USLUGI as "ID_USLUGI",
                                SUM(trzall.SUMMA) as "SUMMA"
                          FROM (
                                 /*(1)������ �� ��������� �����������*/
                                 select SUM(ROUND(trzlocal.SUMMA_ZA_CHTO *
                                                   (trzlocal.TZENA_TERMINALA +
                                                   trzlocal.BASE_DELTA_PRICE) / 100 *
                                                   (trzlocal.OPERATZIYA * 2 - 1),
                                                   '2')) as "SUMMA",
                                         trzlocal.ID_KOSH_ZA_CHTO as "ID_USLUGI",
                                         trzlocal.NOMER_TERMINALA as "TERMINAL"
                                   from ECFIL139 trzlocal --���������� �� ����� ������
                                  where trzlocal.ID_PRICHINY in (11, 24, 25) --������ ������������ �� ������
                                       --  and trzlocal.NOMER_TERMINALA = 8086                                 --���������� ����� ���������
                                    and trzlocal.EM_GDE_OBSL =
                                        (select myemitent.ID_EMITENT
                                           from P5CONFIG myemitent) --����� ����� ��������
                                    and trzlocal.DATA between
                                        to_date('01.05.2016', 'dd.mm.yyyy') --���������� ����� ���� ��
                                        and to_date('31.12.2020', 'dd.mm.yyyy') --���������� ����� ���� ��
                                  group by trzlocal.ID_KOSH_ZA_CHTO,
                                            trzlocal.NOMER_TERMINALA
                                 UNION ALL
                                 /*(2)������ �� ���������� �����������*/
                                 select SUM(ROUND(trztranzit.SUMMA_ZA_CHTO *
                                                   trztranzit.TCHENA_TERMINALA *
                                                   (trztranzit.OPERACHIYA * 2 - 1),
                                                   '2')) as "SUMMA",
                                         trztranzit.ID_ZA_CHTO_MOEGO as "ID_USLUGI",
                                         trztranzit.NOMER_TERMINALA as "TERMINAL"
                                   from ECFIL144 trztranzit --���������� �� ����� ������
                                  where trztranzit.PRICHINA_IZMENENIYA in
                                        (11, 24, 25) --������ ������������ �� ������
                                    and trztranzit.EMITENT_GDE_OBSLUGILIS =
                                        (select myemitent.ID_EMITENT
                                           from P5CONFIG myemitent) --����� ����� ��������                           
                                    and trztranzit.DATA between
                                        to_date('01.05.2016', 'dd.mm.yyyy') --���������� ����� ���� ��
                                        and to_date('31.12.2020', 'dd.mm.yyyy') --���������� ����� ���� ��
                                  group by trztranzit.ID_ZA_CHTO_MOEGO,
                                            trztranzit.NOMER_TERMINALA) trzall
                         GROUP BY trzall.TERMINAL, trzall.ID_USLUGI) TABLE_SUMMY, --(3)������� (�������, ��������, �����)
                       
                       ( /*(4)������ ����������*/
                        select firmy.id_firmy  as "ID_FIRMY",
                                tzena.Id_Uslugi as "ID_USLUGI",
                                tzena.Tzena     as "TARIF"
                          from ECFIL002 firmy, --�������� �����
                                ECFIL116 tzena --������ ������
                         where firmy.Id_Gr_Tarifa_Perescheta =
                               tzena.Id_Gruppy_Dlya_Perescheta --�� ������ ������
                           and tzena.Deleted = 0 --����� �� ������
                        ) TABLE_TARIF, --(4)������� (�������, ��������, %������)
                       
                       ( /*(5)������ ���������� �� ������ ������� - ���������� ��*/
                        select firmy.Id_Firmy as "ID_FIRMY",
                                firmy.Name     as "NAME_FIRMY",
                                num_to.Id_Pos  as "POS_NUMBER"
                          from POSGROUPITEM num_to, --������ �� �� ������ ������ ��
                                POSGROUP     gr_to, --����� ������ �� �� ������ �����
                                ECFIL078     privazka, --�������� �� ������� � ������ �������
                                ECFIL002     firmy --�������� �����
                         where num_to.id_group = gr_to.id -- �� ������ ��
                           and privazka.Id_Prinadl = 2 --������ ��
                           and privazka.Id_Gruppy = 9 --����� ������ [9] ���������� �� (805 �������)
                           and privazka.id_klienta = gr_to.id_firm --�� �������
                           and privazka.id_klienta = firmy.id_firmy --�� �������
                        ) TABLE_MAIN_TERMINAL --(5) (�������, �������������, ����������)
                
                 WHERE TABLE_MAIN_TERMINAL.ID_FIRMY = TABLE_TARIF.ID_FIRMY
                   AND TABLE_TARIF.ID_USLUGI = TABLE_SUMMY.ID_USLUGI
                   AND TABLE_MAIN_TERMINAL.POS_NUMBER =
                       TABLE_SUMMY.POS_NUMBER) TABLE_SUMMY_PO_VIDAM
        
         GROUP BY TABLE_SUMMY_PO_VIDAM.ID_FIRMY,
                  TABLE_SUMMY_PO_VIDAM.NAME_FIRMY) TABLE_PRODUCT, --������� ������� (�������, ��������, ��������������)
       
       /*()����� ��������� � ��������*/
       (select payment.id_vlad as "ID_FIRMY",
               sum(payment.summa *
                   decode(payment.operachiya, 4, -1, 14, -1, 1, 1, 12, 1)) as "PAYMENT" --4,14-�������� � 1,12-���������
          from ECFIL096 payment --����������
         where payment.data between to_date('01.05.2016', 'dd.mm.yyyy') --���������� ����� ���� ��
               and to_date('31.12.2020', 'dd.mm.yyyy') --���������� ����� ���� �� 
           and payment.id_prinadl = 2 --������ �����
           and payment.id_kosh = 1 --������ �����
         group by payment.id_vlad) TABLE_PAYMENT, --������� �������� (�������, �����)
       ECFIL078 privazka_k_gruppe, --�������� �� ������� � ������ �������
       ECFIL002 nazvanie_firmy --�������� �����
 WHERE privazka_k_gruppe.id_gruppy = 9 --����� ������ [9] ���������� �� (805 �������)
   AND privazka_k_gruppe.id_klienta = TABLE_PRODUCT.ID_FIRMY(+)
   AND privazka_k_gruppe.id_klienta = TABLE_PAYMENT.ID_FIRMY(+)
   AND privazka_k_gruppe.id_klienta = nazvanie_firmy.id_firmy(+)
 ORDER BY 1

BEGIN
 DBMS_OUTPUT.ENABLE(1500000);
FOR ROW in OTK
 LOOP
   dbms_output.put_line(row.ID_CLIENTA||';'||row.NAME||';'||row.U_KOGO_ZAPRAVILIS||';'||row.KTO_ZAPRAVILSA||';'||row.OPLATA);
END LOOP;
END;
/

select to_char(sysdate, 'dd/mm/yyyy HH24:MI:SS') as DATA_VREMYA
from DUAL;

SPOOL OFF
SET SERVEROUTPUT OFF
SET TERMOUT ON
SET ECHO ON
EXIT
