select air_temp_indication.* from air_temp_indication join main.air a on air_temp_indication.id = a.temp_id join main.indication i on a.id = i.air_id where i.id = 10514735;
