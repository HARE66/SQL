select firmy.Id_Firmy, firmy.Name, num_to.Id_Pos, tzena.Id_Uslugi, tzena.Tzena
from POSGROUPITEM num_to, --������ �� �� ������ ������ ��
     POSGROUP gr_to, --����� ������ �� �� ������ �����
     ECFIL078 privazka, --�������� �� ������� � ������ �������
     ECFIL002 firmy, --�������� �����
     ECFIL116 tzena --������ ������
     
where num_to.id_group = gr_to.id -- �� ������ ��
--and gr_to.id_firm = 169
and privazka.Id_Prinadl = 2 --������ ��
and privazka.Id_Gruppy = 9 --����� ������ [9] ���������� �� (805 �������)
and privazka.id_klienta = gr_to.id_firm --�� �������
and privazka.id_klienta = firmy.id_firmy --�� �������
and firmy.Id_Gr_Tarifa_Perescheta = tzena.Id_Gruppy_Dlya_Perescheta --�� ������ ������
and tzena.Deleted = 0 --����� �� ������

order by 3, 4
