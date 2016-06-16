/*����� ���� ���������� �� ����������*/
SELECT TERMINAL as "POS_NUMBER", 
ID_USLUGI as "ID_USLUGI", 
SUM(SUMMA) as "SUMMA"

FROM

(
/*������ �� ��������� �����������*/
select SUM (ROUND (trzlocal.SUMMA_ZA_CHTO * (trzlocal.TZENA_TERMINALA + trzlocal.BASE_DELTA_PRICE) / 100 * (trzlocal.OPERATZIYA*2-1),'2')) as "SUMMA",
trzlocal.ID_KOSH_ZA_CHTO as "ID_USLUGI",
trzlocal.NOMER_TERMINALA as "TERMINAL"
from ECFIL139 trzlocal           --���������� �� ����� ������
where
      trzlocal.ID_PRICHINY in (11,24,25)                       --������ ������������ �� ������
--  and trzlocal.NOMER_TERMINALA = 8086                                 --���������� ����� ���������
  and trzlocal.EM_GDE_OBSL = (select myemitent.ID_EMITENT from P5CONFIG myemitent)      --����� ����� ��������
  and trzlocal.DATA between to_date('01.04.2016','dd.mm.yyyy')     --���������� ����� ���� ��
  and to_date('30.04.2016','dd.mm.yyyy')                      --���������� ����� ���� ��
group by trzlocal.ID_KOSH_ZA_CHTO,
         trzlocal.NOMER_TERMINALA

UNION ALL

/*������ �� ���������� �����������*/
select SUM (ROUND (trztranzit.SUMMA_ZA_CHTO*trztranzit.TCHENA_TERMINALA * (trztranzit.OPERACHIYA*2-1),'2')) as "SUMMA", 
trztranzit.ID_ZA_CHTO_MOEGO as "ID_USLUGI",
trztranzit.NOMER_TERMINALA as "TERMINAL"
from ECFIL144 trztranzit           --���������� �� ����� ������
where
      trztranzit.PRICHINA_IZMENENIYA in (11,24,25)                       --������ ������������ �� ������
--  and trztranzit.NOMER_TERMINALA = 8086    --���������� ����� ���������
  and trztranzit.EMITENT_GDE_OBSLUGILIS = (select myemitent.ID_EMITENT from P5CONFIG myemitent)      --����� ����� ��������                           
  and trztranzit.DATA between to_date('01.04.2016','dd.mm.yyyy')     --���������� ����� ���� ��
  and to_date('30.04.2016','dd.mm.yyyy')                      --���������� ����� ���� ��
group by trztranzit.ID_ZA_CHTO_MOEGO,
         trztranzit.NOMER_TERMINALA

) trzall

GROUP BY trzall.TERMINAL, trzall.ID_USLUGI
