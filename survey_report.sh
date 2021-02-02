fileName="survey_report.txt"
recipientEmailAddress=$1
emailSubject="Survey Status Report"
emailBody="Hello,

The Survey Invitation Summary Report is attached herewith. 

The report is generated for the below details:
Collection Protocol Id: 
Start date:
End date:
 
Thank you,
OpenSpecimen Administrator"

query="SELECT  survey_status, 
       Count(survey_status) Number_of_Survey 
FROM   (SELECT S.cp_id, 
               cpr.protocol_participant_id, 
               S.title, 
               SI.survey_id, 
               SI.expiry_time, 
               CASE 
                 WHEN SI.status = 'CLOSED' THEN 'Closed' 
                 WHEN SI.status = 'COMPLETED' THEN 'Completed' 
                 WHEN SI.status = 'PENDING_INV_OPENED' 
                      AND SI.expiry_time > Curtime() THEN 'Mail Opened' 
                 WHEN SI.status = 'PENDING_SRV_OPENED' 
                      AND SI.expiry_time > Curtime() THEN 'Survey Opened' 
                 WHEN SI.status='PENDING' AND SI.expiry_time > Curtime() THEN 'Pending' 
                 WHEN SI.status IN('PENDING', 'PENDING_INV_OPENED', 
                                    'PENDING_SRV_OPENED' ) 
                      AND SI.expiry_time < Curtime() THEN 'Expired' 
               END AS Survey_Status 
        FROM   os_surveys S 
               JOIN os_survey_instances SI 
                 ON s.identifier = si.survey_id 
               JOIN catissue_coll_prot_reg cpr 
                 ON si.cpr_id = cpr.identifier 
        WHERE  S.cp_id = 2 
               AND cpr.activity_status = 'Active') View_Survey 
GROUP  BY survey_status;"


generateSurveyStatusReport(){
	mysql --user="os_tester" --password="secrete" --database="os_mysql" --execute="$query" >  /home/krishagni/openspecimen/data/$fileName
}

sendEmail(){
	mail -s "$emailSubject" $recipientEmailAddress -A $fileName <<< $emailBody
}

main(){	
	generateSurveyStatusReport;
	sendEmail;
}

main;
