/*������ ����������*/
select firmy.id_firmy as "ID_FIRMY", 
tzena.Id_Uslugi as "ID_USLUGI", 
tzena.Tzena as "TARIF"
from
 ECFIL002 firmy, --�������� �����
 ECFIL116 tzena --������ ������
where firmy.Id_Gr_Tarifa_Perescheta = tzena.Id_Gruppy_Dlya_Perescheta --�� ������ ������
and tzena.Deleted = 0 --����� �� ������
