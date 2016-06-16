/*������ ���������� �� ������ ������� - ���������� ��*/
select firmy.Id_Firmy as "ID_FIRMY",
  firmy.Name as "NAME_FIRMY",
  num_to.Id_Pos as "POS_NUMBER"

from POSGROUPITEM num_to, --������ �� �� ������ ������ ��
     POSGROUP gr_to, --����� ������ �� �� ������ �����
     ECFIL078 privazka, --�������� �� ������� � ������ �������
     ECFIL002 firmy --�������� �����
     
where num_to.id_group = gr_to.id -- �� ������ ��
--and gr_to.id_firm = 169
and privazka.Id_Prinadl = 2 --������ ��
and privazka.Id_Gruppy = 9 --����� ������ [9] ���������� �� (805 �������)
and privazka.id_klienta = gr_to.id_firm --�� �������
and privazka.id_klienta = firmy.id_firmy --�� �������

