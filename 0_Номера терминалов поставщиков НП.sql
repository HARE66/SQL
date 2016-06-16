/*Номера терминалов из группы клиентв - Поставщики НП*/
select firmy.Id_Firmy as "ID_FIRMY",
  firmy.Name as "NAME_FIRMY",
  num_to.Id_Pos as "POS_NUMBER"

from POSGROUPITEM num_to, --номера ТО по номеру группы ТО
     POSGROUP gr_to, --номер группы ТО по номеру фирмы
     ECFIL078 privazka, --привязки ИД Клиента к группе клиента
     ECFIL002 firmy --название фирмы
     
where num_to.id_group = gr_to.id -- ИД группы ТО
--and gr_to.id_firm = 169
and privazka.Id_Prinadl = 2 --группы ЮЛ
and privazka.Id_Gruppy = 9 --номер группы [9] Поставщики НП (805 эквайер)
and privazka.id_klienta = gr_to.id_firm --ИД Клиента
and privazka.id_klienta = firmy.id_firmy --ИД Клиента

