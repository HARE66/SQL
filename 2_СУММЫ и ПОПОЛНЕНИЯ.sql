SELECT 
TABLE_SUMMY_PO_VIDAM.ID_FIRMY as "ID_FIRMY",
TABLE_SUMMY_PO_VIDAM.NAME_FIRMY as "NAME_FIRMY",
SUM(TABLE_SUMMY_PO_VIDAM.SUMMA_SO_SKIDKOI) as "SUMMA_SO_SKIDKOI"
FROM
(
SELECT
--TABLE_SUMMY.POS_NUMBER,
TABLE_SUMMY.ID_USLUGI as "ID_USLUGI",
TABLE_SUMMY.SUMMA as "SUMMA",
TABLE_TARIF.TARIF as "TARIF",
ROUND (TABLE_SUMMY.SUMMA * (100-TABLE_TARIF.TARIF) / 100, 2) as "SUMMA_SO_SKIDKOI",
TABLE_MAIN_TERMINAL.ID_FIRMY as "ID_FIRMY",
TABLE_MAIN_TERMINAL.NAME_FIRMY as "NAME_FIRMY"
FROM

(/*Суммы всех транзакций по терминалам*/
SELECT trzall.TERMINAL as "POS_NUMBER", 
trzall.ID_USLUGI as "ID_USLUGI", 
SUM(trzall.SUMMA) as "SUMMA"
FROM
(
/*Запрос по локальным транзакциям*/
select SUM (ROUND (trzlocal.SUMMA_ZA_CHTO * (trzlocal.TZENA_TERMINALA + trzlocal.BASE_DELTA_PRICE) / 100 * (trzlocal.OPERATZIYA*2-1),'2')) as "SUMMA",
trzlocal.ID_KOSH_ZA_CHTO as "ID_USLUGI",
trzlocal.NOMER_TERMINALA as "TERMINAL"
from ECFIL139 trzlocal           --Транзакции по своим картам
where
      trzlocal.ID_PRICHINY in (11,24,25)                       --только обслуживания по картам
--  and trzlocal.NOMER_TERMINALA = 8086                                 --переменная номер терминала
  and trzlocal.EM_GDE_OBSL = (select myemitent.ID_EMITENT from P5CONFIG myemitent)      --номер моего эмитента
  and trzlocal.DATA between to_date('01.04.2016','dd.mm.yyyy')     --переменная ВВОДА дата от
  and to_date('30.04.2016','dd.mm.yyyy')                      --переменная ВВОДА дата до
group by trzlocal.ID_KOSH_ZA_CHTO,
         trzlocal.NOMER_TERMINALA
UNION ALL
/*Запрос по транзитным транзакциям*/
select SUM (ROUND (trztranzit.SUMMA_ZA_CHTO*trztranzit.TCHENA_TERMINALA * (trztranzit.OPERACHIYA*2-1),'2')) as "SUMMA", 
trztranzit.ID_ZA_CHTO_MOEGO as "ID_USLUGI",
trztranzit.NOMER_TERMINALA as "TERMINAL"
from ECFIL144 trztranzit           --Транзакции по чужим картам
where
      trztranzit.PRICHINA_IZMENENIYA in (11,24,25)                       --только обслуживания по картам
  and trztranzit.EMITENT_GDE_OBSLUGILIS = (select myemitent.ID_EMITENT from P5CONFIG myemitent)      --номер моего эмитента                           
  and trztranzit.DATA between to_date('01.04.2016','dd.mm.yyyy')     --переменная ВВОДА дата от
  and to_date('30.04.2016','dd.mm.yyyy')                      --переменная ВВОДА дата до
group by trztranzit.ID_ZA_CHTO_MOEGO,
         trztranzit.NOMER_TERMINALA
) trzall
GROUP BY trzall.TERMINAL, trzall.ID_USLUGI
) TABLE_SUMMY,

(/*Тарифы терминалов*/
select firmy.id_firmy as "ID_FIRMY", 
tzena.Id_Uslugi as "ID_USLUGI", 
tzena.Tzena as "TARIF"
from
 ECFIL002 firmy, --название фирмы
 ECFIL116 tzena --тарифы скидок
where firmy.Id_Gr_Tarifa_Perescheta = tzena.Id_Gruppy_Dlya_Perescheta --ИД Группы тарифа
and tzena.Deleted = 0 --Тариф не уделен
) TABLE_TARIF,

(/*Номера терминалов из группы клиентв - Поставщики НП*/
select firmy.Id_Firmy as "ID_FIRMY",
  firmy.Name as "NAME_FIRMY",
  num_to.Id_Pos as "POS_NUMBER"

from POSGROUPITEM num_to, --номера ТО по номеру группы ТО
     POSGROUP gr_to, --номер группы ТО по номеру фирмы
     ECFIL078 privazka, --привязки ИД Клиента к группе клиента
     ECFIL002 firmy --название фирмы
     
where num_to.id_group = gr_to.id -- ИД группы ТО
and privazka.Id_Prinadl = 2 --группы ЮЛ
and privazka.Id_Gruppy = 9 --номер группы [9] Поставщики НП (805 эквайер)
and privazka.id_klienta = gr_to.id_firm --ИД Клиента
and privazka.id_klienta = firmy.id_firmy --ИД Клиента
) TABLE_MAIN_TERMINAL

WHERE 
TABLE_MAIN_TERMINAL.ID_FIRMY = TABLE_TARIF.ID_FIRMY
AND
TABLE_TARIF.ID_USLUGI = TABLE_SUMMY.ID_USLUGI
AND
TABLE_MAIN_TERMINAL.POS_NUMBER = TABLE_SUMMY.POS_NUMBER
) TABLE_SUMMY_PO_VIDAM,

ECFIL139 POPOLNENIYA

WHERE POPOLNENIYA.ID_KLIENTA = TABLE_SUMMY_PO_VIDAM.

GROUP BY TABLE_SUMMY_PO_VIDAM.ID_FIRMY, TABLE_SUMMY_PO_VIDAM.NAME_FIRMY
