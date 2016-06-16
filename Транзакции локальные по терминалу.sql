select SUM (ROUND (trzlocal.SUMMA_ZA_CHTO * (trzlocal.TZENA_TERMINALA + trzlocal.BASE_DELTA_PRICE) / 100 * (trzlocal.OPERATZIYA*2-1),'2')) as "SUMMA",
trzlocal.ID_KOSH_ZA_CHTO as "ID_USLUGI"
--select trzlocal.data, trzlocal.SUMMA_ZA_CHTO, trzlocal.TZENA_TERMINALA, trzlocal.OPERATZIYA
from ECFIL139 trzlocal           --Транзакции по своим картам
where
      trzlocal.ID_PRICHINY in (11,24,25)                       --только обслуживания по картам
  and trzlocal.NOMER_TERMINALA = 8086                                 --переменная номер терминала
  and trzlocal.EM_GDE_OBSL = (select myemitent.ID_EMITENT from P5CONFIG myemitent)      --номер моего эмитента
  and trzlocal.DATA between to_date('01.04.2016','dd.mm.yyyy')     --переменная ВВОДА дата от
  and to_date('10.04.2016','dd.mm.yyyy')                      --переменная ВВОДА дата до
group by trzlocal.ID_KOSH_ZA_CHTO
