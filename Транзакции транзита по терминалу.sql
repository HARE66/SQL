select SUM (ROUND (trztranzit.SUMMA_ZA_CHTO*trztranzit.TCHENA_TERMINALA * (trztranzit.OPERACHIYA*2-1),'2')) as "SUMMA", 
trztranzit.ID_ZA_CHTO_MOEGO as "ID_USLUGI"
--select trztranzit.data, trztranzit.SUMMA_ZA_CHTO, trztranzit.TCHENA_TERMINALA, trztranzit.OPERACHIYA
from ECFIL144 trztranzit           --���������� �� ����� ������
where
      trztranzit.PRICHINA_IZMENENIYA in (11,24,25)                       --������ ������������ �� ������
  and trztranzit.nomer_terminala = 8086    --���������� ����� ���������
  and trztranzit.EMITENT_GDE_OBSLUGILIS = (select myemitent.ID_EMITENT from P5CONFIG myemitent)      --����� ����� ��������                           
  and trztranzit.DATA between to_date('01.04.2016','dd.mm.yyyy')     --���������� ����� ���� ��
  and to_date('10.04.2016','dd.mm.yyyy')                      --���������� ����� ���� ��
group by trztranzit.ID_ZA_CHTO_MOEGO
