
USE [Data_Lab_NCL]

-- NOTE: Run the OP script first before running this one as this is needed when updating the [dbo].[daycase_rates] table

-- Work in Progress:
	-- Amend scripts to link to Unified SUS
	-- Need to amend OP script to add the Non-HVLC procedures
	-- Need to split script into Specialties or create a reference table with a complete list of OPCS and ICD10 codes

-- Total duration: 3mins and 17seconds
--------------------------------------------- INPATIENT - START --------------------------------------------

If(OBJECT_ID('tempdb..#DCRate') Is Not Null)
Begin
    Drop Table #DCRate
End

select 
case when FinYear = '2022/2023' Then '2022/23'
		when FinYear = '2023/2024' Then '2023/24'
--case when FinYear = '2018/2019' Then '2018/19'
--	when FinYear = '2019/2020' Then '2019/20'
--	when FinYear = '2020/2021' Then '2020/21'
--	when FinYear = '2021/2022' Then '2021/22'
--	when FinYear = '2022/2023' Then '2022/23'
		End as [FinYear]
,[Month]
,Qtr
,[Adult/Paed]
,[Provider Name]
,case when left([Provider Code],3) = 'RAP' Then 'North Middlesex'
		when left([Provider Code],3) = 'RRV' Then 'UCLH'
		when left([Provider Code],3) = 'RKE' Then 'Whittington'
		when left([Provider Code],3) = 'RAL' Then 'Royal Free'
		when left([Provider Code],3) = 'RAN' Then 'RNOH'
		when left([Provider Code],3) = 'RP6' Then 'Moorfields'
		when left([Provider Code],3) = 'RP4' Then 'GOSH'
		when [Provider Code] = 'NT451' Then 'BMI Cavell'
		when [Provider Code] = 'NT421' Then 'Kings Oak'
		when [Provider Code] = 'NT416' Then 'Hendon'
		when [Provider Code] in ('NYW03','G3Q3Z') Then 'Highgate'
			End as [Provider]
--,[HRG Code] + ' - ' + [HRG Desc] as HRG
--,[Procedure Code] + ' - ' + [Procedure Desc] as [Procedure]
,POD
,case when [Procedures] in (select metric from [Data_Lab_NCL].dbo.daycase_metrics) Then Specialty
		when [Procedures] is NULL and [Procedure Sub Category] in (select metric from [Data_Lab_NCL].dbo.daycase_metrics) Then Specialty
		when [Procedures] is NULL and [Procedure Sub Category] is NULL and Treatment_Function_Code in ('120','215') Then 'Ear, Nose & Throat'
		when [Procedures] is NULL and [Procedure Sub Category] is NULL and Treatment_Function_Code in ('502','503') Then 'Gynaecology'
		when [Procedures] is NULL and [Procedure Sub Category] is NULL and Treatment_Function_Code in ('130','216') Then 'Ophthalmology'
		when [Procedures] is NULL and [Procedure Sub Category] is NULL and Treatment_Function_Code in ('101','211') Then 'Urology'
		when [Procedures] is NULL and [Procedure Sub Category] is NULL and Treatment_Function_Code in ('110','214') Then 'Trauma & Orthopaedics'
		when [Procedures] is NULL and [Procedure Sub Category] is NULL and Treatment_Function_Code in ('100','102','103','104','105','106','107','108','109')  Then 'General Surgery'
			Else 'Other' 
				End as [Grouped Specialty]
--,case	when [Procedures] in ('HVLC Endoscopic Sinus Surgery','HVLC Myringoplasty','HVLC Septoplasty and Turbinate','HVLC Septorhinoplasty','HVLC Tonsillectomy','Mastoidectomy','Stapediectomy','Tympanoplasty','Septoplasty') Then 'Ear, Nose & Throat'
--		when [Procedures] in ('HVLC Endometrial ablation','HVLC Hysteroscopy','HVLC Laparoscopic hysterectomy','HVLC Operative laparoscopy','HVLC Vaginal hysterectomy and/or vaginal wall repair','Vaginal hysterectomy','Anterior or posterior vaginal repair') Then 'Gynaecology'
--		when [Procedures] in ('HVLC Low complexity cataract surgery','Vitrectomy') Then 'Ophthalmology'
--		when [Procedures] in ('HVLC Bladder outflow obstruction','HVLC Cystoscopy plus','HVLC Minor peno-scrotal surgery','HVLC Bladder tumour resection (TURBT)','HVLC Ureteroscopy and stent management','Transurethral resection of prostate (TURP)','Laser destruction of prostate','Ureteroscopic destruction of calculus in ureter','Endoscopic insertion of prosthesis into ureter') Then 'Urology'
--		when [Procedures] in ('HVLC Anterior cruciate ligament reconstruction','HVLC Bunions','HVLC Therapeutic shoulder arthroscopy','HVLC Total hip replacement','HVLC Total knee replacement','HVLC Uni knee replacement') Then 'Trauma & Orthopaedics'
--		when [Procedures] in ('HVLC Laparoscopic cholecystectomy','HVLC Primary inguinal hernia repair','HVLC Para-umbilical hernia','Haemorrhoids/Anal Fissure surgery','Laparoscopic repair of hiatus hernia with anti-reflux procedure','Primary repair of femoral hernia','Repair of recurrent inguinal hernia') Then 'General Surgery'
--		when [Procedures] in ('HVLC Cervical spine decompression / fusion','HVLC Lumbar Decompression / Discectomy','HVLC Lumbar nerve root block / therapeutic epidural injection','HVLC Lumbar medial branch block/facet joint injections','HVLC 1 or 2 Level Posterior Fusion') Then 'Spinal'
--		when [Procedures] in (select [Metric] from [dbo].[daycase_metrics]) Then dc.[Specialty]
--		when Treatment_Function_Code in ('120','215') Then 'Ear, Nose & Throat'
--		when Treatment_Function_Code in ('502','503') Then 'Gynaecology'
--		when Treatment_Function_Code in ('130','216') Then 'Ophthalmology'
--		when Treatment_Function_Code in ('101','211') Then 'Urology'
--		when Treatment_Function_Code in ('110','214') Then 'Trauma & Orthopaedics'
--		when Treatment_Function_Code in ('100','102','103','104','105','106','107','108','109')  Then 'General Surgery'
--			Else 'Other'
--					End as [Grouped Specialty]
--,Treatment_Function_Code + ' - ' + [TFC Desc] as [Treatment Function]
--,Main_Specialty_Code + ' - ' + [Main Specialty] as [Main Specialty]
,[Procedures]
,[Procedure Sub Category]
,case when [Procedures] like 'HVLC%' Then 'HVLC Procedures' Else 'Non-HVLC Procedures' End as [HVLC Flag]
,case	when [Procedures] = 'HVLC Endoscopic Sinus Surgery' Then .95
		when [Procedures] = 'HVLC Myringoplasty' Then .95
		when [Procedures] = 'HVLC Septoplasty and Turbinate' Then .95
		when [Procedures] = 'HVLC Septorhinoplasty' Then .90
		when [Procedures] = 'HVLC Tonsillectomy' Then .90
		when [Procedures] = 'HVLC Laparoscopic cholecystectomy' Then .75
		when [Procedures] = 'HVLC Primary inguinal hernia repair' Then .90
		when [Procedures] = 'HVLC Para-umbilical hernia' Then .90	
		when [Procedures] = 'HVLC Endometrial ablation' Then .983
		when [Procedures] = 'HVLC Hysteroscopy' Then .96
		when [Procedures] = 'HVLC Laparoscopic hysterectomy' Then .041
		when [Procedures] = 'HVLC Operative laparoscopy' Then .84
		when [Procedures] = 'HVLC Vaginal hysterectomy and/or vaginal wall repair' Then .204
		when [Procedures] = 'HVLC Low complexity cataract surgery' Then 1
		when [Procedures] = 'HVLC Bladder outflow obstruction' Then .25
		when [Procedures] = 'HVLC Cystoscopy plus' Then .80
		when [Procedures] = 'HVLC Minor peno-scrotal surgery' Then .96
		when [Procedures] = 'HVLC Bladder tumour resection (TURBT)' Then .43
		when [Procedures] = 'HVLC Ureteroscopy and stent management' Then .80
		when [Procedures] = 'HVLC Anterior cruciate ligament reconstruction' Then .90
		when [Procedures] = 'HVLC Bunions' Then .95
		when [Procedures] = 'HVLC Therapeutic shoulder arthroscopy' Then .90
		when [Procedures] = 'HVLC Total hip replacement' Then .10
		when [Procedures] = 'HVLC Total knee replacement' Then .10
		when [Procedures] = 'HVLC Uni knee replacement' Then .40
		--when [Procedures] = 'Cervical spine decompression / fusion' Then -- NO TARGET?
		--when [Procedures] = 'Lumbar Decompression / Discectomy' Then -- NO TARGET?
		when [Procedures] = 'HVLC Lumbar nerve root block / therapeutic epidural injection' Then 1
		when [Procedures] = 'HVLC Lumbar medial branch block/facet joint injections' Then 1
		--when [Procedures] = '1 or 2 Level Posterior Fusion' Then -- NO TARGET?
		--when [Procedures] = 'Adenoid Surgery' Then 1
		--when [Procedures] = 'Diagnostic endoscopic examination of pharynx / larynx ± biopsy' Then .99
		--when [Procedures] = 'Excision pre-auricular abnormality' Then 1
		--when [Procedures] = 'Excison / biopsy of lesion of pinna' Then 1
			End as Benchmark
,[Booked vs Admission Type]
,[Grouped LoS]
,[Age Group]
,[Critical care Flag]
,[Excluded Flag]
,[NCL\Non-NCL]
,sum(Elective) as Elective
,sum(Daycase) as Daycase
,SUM(activity) as [Activity]

into #DCRate

from
(
select
SK_PatientID
,DW_NHS_Number
,Spell_Identifier
,[dv_FinYear] as FinYear
,case when [dv_FinMonth] = 1 Then 'Apr'
		when [dv_FinMonth] = 2 Then 'May'
		when [dv_FinMonth] = 3 Then 'Jun'
		when [dv_FinMonth] = 4 Then 'Jul'
		when [dv_FinMonth] = 5 Then 'Aug'
		when [dv_FinMonth] = 6 Then 'Sep'
		when [dv_FinMonth] = 7 Then 'Oct'
		when [dv_FinMonth] = 8 Then 'Nov'
		when [dv_FinMonth] = 9 Then 'Dec'
		when [dv_FinMonth] = 10 Then 'Jan'
		when [dv_FinMonth] = 11 Then 'Feb'
		when [dv_FinMonth] = 12 Then 'Mar'
			End as [Month]
,case when dv_FinMonth <4 Then 'Q1'
		when dv_FinMonth between 4 and 6 Then 'Q2'
		when dv_FinMonth between 7 and 9 Then 'Q3'
		when dv_FinMonth > 9 Then 'Q4'
			End as Qtr
,[dv_LengthOfStay_Gross] as LoS
,case when [dv_LengthOfStay_Gross] = 0 Then '0 day'
		when [dv_LengthOfStay_Gross] = 1 Then '1 day'
			Else '>1 day'
				End as [Grouped LoS]
,[Patient_Classification] as Pat_Class
,[Admission_Method_Hospital_Provider_Spell] as Adm_Method
,case when [Age_At_CDS_Activity_Date] < 17 Then 'Paediatric (0-16)'
		when [Age_At_CDS_Activity_Date] > 16 Then 'Adult (17 & above)'
			Else 'Invalid/Missing'
				End as [Adult/Paed]
,[Treatment_Function_Code] 
,tfc.[SpecialtyName] as [TFC Desc]
,Main_Specialty_Code
,spec.[SpecialtyName] as [Main Specialty]
,[Organisation_Code_Code_of_Provider] as [Provider Code]
,org.Organisation_Name  as [Provider Name]
,[Spell_Core_HRG] as [HRG Code]
,hrg.[HRGDescription] as [HRG Desc]
,Primary_Procedure_Code as [Procedure Code]
,opcs.[Description] as [Procedure Desc]
,secondary_Procedure_Code_1
,secondary_Procedure_Code_2
,secondary_Procedure_Code_3
,secondary_Procedure_Code_4
,secondary_Procedure_Code_5
,secondary_Procedure_Code_6
,secondary_Procedure_Code_7
,secondary_Procedure_Code_8
,secondary_Procedure_Code_9
,secondary_Procedure_Code_10
,secondary_Procedure_Code_11
,secondary_Procedure_Code_12
,case when SK_EncounterID in (select SK_EncounterID from [SUS].[IP].[EncounterCriticalCare_DateRange]) Then 'Yes' Else 'No' End as [Critical care Flag]
,case when Age_At_CDS_Activity_Date < 25 Then 'Under 25'
		when Age_At_CDS_Activity_Date between 25 and 29 Then '25 - 29'
		when Age_At_CDS_Activity_Date between 30 and 34 Then '30 - 34'
		when Age_At_CDS_Activity_Date between 35 and 39 Then '35 - 39'
		when Age_At_CDS_Activity_Date between 40 and 44 Then '40 - 44'
		when Age_At_CDS_Activity_Date between 45 and 50 Then '45 - 49'
		when Age_At_CDS_Activity_Date between 50 and 54 Then '50 - 54'
		when Age_At_CDS_Activity_Date between 55 and 59 Then '55 - 59'
		when Age_At_CDS_Activity_Date > 59 Then '60 & Over'
			End as [Age Group] 

--- ENT
,case	when (Treatment_Function_Code in ('120','215') or Main_Specialty_Code = '120') and 
			 (left(Primary_Procedure_Code,4) in ('E133','E142','E081','E148','E132','E143') and 
			 SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'Y761')) and
			 SK_EncounterID not in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_diag_vw where left(diag,4) in ('C01X','C051','C052','C07X','C080','C081','C089','C090','C091','C098','C099','C100','C101','C102','C103','C108','C109','C110','C111','C112','C113','C118','C119','C12X','C130','C131','C132','C138','C139','C320','C321','C322','C328','C329','C73X'))
				Then 'HVLC Endoscopic Sinus Surgery' -- as per GIRFT HVLC Pathways – Code Group Recipes and GIRFT_Metadata_ENT file documents. 
													 -- one of the opcs codes (D142) for this procedure is the same as used for Functional endoscopic sinus surgery (FESS)

		when (Treatment_Function_Code in ('120','215') or Main_Specialty_Code = '120') and
			 left(Primary_Procedure_Code,4) in ('D141','D142','D148','D149') and
			 SK_EncounterID not in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_diag_vw where left(diag,4) in ('C01X','C051','C052','C07X','C080','C081','C089','C090','C091','C098','C099','C100','C101','C102','C103','C108','C109','C110','C111','C112','C113','C118','C119','C12X','C130','C131','C132','C138','C139','C320','C321','C322','C328','C329','C73X'))
				Then 'HVLC Myringoplasty' -- as per GIRFT HVLC Pathways – Code Group Recipes and GIRFT_Metadata_ENT file documents
									 -- This procedure has the same codes as Tympanoplasty except D144 where it only applies to Tympanoplasty. It will be in Sub Category

		when (Treatment_Function_Code in ('120','215') or Main_Specialty_Code = '120') and
			 left(Primary_Procedure_Code,4) in  ('E036','E041','E042','E043','E044','E045','E046','E047','E048','E049') and
			 SK_EncounterID not in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_diag_vw where left(diag,4) in ('C01X','C051','C052','C07X','C080','C081','C089','C090','C091','C098','C099','C100','C101','C102','C103','C108','C109','C110','C111','C112','C113','C118','C119','C12X','C130','C131','C132','C138','C139','C320','C321','C322','C328','C329','C73X'))
				Then 'HVLC Septoplasty and Turbinate' -- as per GIRFT HVLC Pathways – Code Group Recipes and GIRFT_Metadata_ENT file documents (BADS definition). 
												 -- In GIRFT it combines Septoplasty and Turbinate. Septoplasty can be identified by opcs code E036 and will be in Sub Category

		when (Treatment_Function_Code in ('120','215') or Main_Specialty_Code = '120') and
			 left(Primary_Procedure_Code,4) in ('E023','E024','E073') and
			 SK_EncounterID not in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_diag_vw where left(diag,4) in ('C01X','C051','C052','C07X','C080','C081','C089','C090','C091','C098','C099','C100','C101','C102','C103','C108','C109','C110','C111','C112','C113','C118','C119','C12X','C130','C131','C132','C138','C139','C320','C321','C322','C328','C329','C73X'))
				Then 'HVLC Septorhinoplasty' -- as per GIRFT HVLC Pathways – Code Group Recipes and GIRFT_Metadata_ENT file documents
											 -- also known as Septorhinoplasty ± graft / implant

		when (Treatment_Function_Code in ('120','215') or Main_Specialty_Code = '120') and
			 ((left(Primary_Procedure_Code,4) in ('F341','F342','F343','F344','F345','F347','F348','F349') and SK_EncounterID not in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('D345','F346'))) 
			 and SK_EncounterID not in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_diag_vw where left(diag,4) in ('C01X','C051','C052','C07X','C080','C081','C089','C090','C091','C098','C099','C100','C101','C102','C103','C108','C109','C110','C111','C112','C113','C118','C119','C12X','C130','C131','C132','C138','C139','C320','C321','C322','C328','C329','C73X')))
				Then 'HVLC Tonsillectomy' --as per GIRFT HVLC Pathways – Code Group Recipes and GIRFT_Metadata_ENT file documents

		when (Treatment_Function_Code in ('120','215') or Main_Specialty_Code = '120') and
			 left(Primary_Procedure_Code,4) in ('D102','D103','D104')
				Then 'Modified radical mastoidectomy (including meatoplasty)' -- As per GIRFT_Metadata_ENT file documents (BADS definition)

		--when (Treatment_Function_Code in ('120','215') or Main_Specialty_Code = '120') and
		--	 left(Primary_Procedure_Code,4) = 'D171'
		--		Then 'Stapediectomy' -- not in GIRFT nor BADS. Used the code in Sui's and Peter's scripts for D&C Modelling

		-- 19/01/2023 Added as part of the DC Monitoring report as NHSE set a target of 85%
		when (Treatment_Function_Code in ('120','215') or Main_Specialty_Code = '120') and
			 (left(Primary_Procedure_Code,4) in ('E201','E202','E204','E208','E209') and SK_EncounterID not in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'E203'))
				Then 'Adenoid Surgery'

		when (Treatment_Function_Code in ('120','215') or Main_Specialty_Code = '120') and
			 LEFT(Primary_Procedure_Code,3) in ('E25','E36','E37')
				Then 'Diagnostic endoscopic examination of pharynx / larynx ± biopsy'

		when (Treatment_Function_Code in ('120','215') or Main_Specialty_Code = '120') and
			 LEFT(Primary_Procedure_Code,4) = 'D013'
				Then 'Excision pre-auricular abnormality'

		when (Treatment_Function_Code in ('120','215') or Main_Specialty_Code = '120') and
			 (LEFT(Primary_Procedure_Code,3) = 'D02' or LEFT(Primary_Procedure_Code,4) = 'D061')
				Then 'Excison / biopsy of lesion of pinna'

		when (Treatment_Function_Code in ('120','215') or Main_Specialty_Code = '120') and
			 LEFT(Primary_Procedure_Code,3) = 'E34'
				Then 'Laser surgery to vocal cord (including microlaryngoscopy)'

		when (Treatment_Function_Code in ('120','215') or Main_Specialty_Code = '120') and
			 LEFT(Primary_Procedure_Code,4) in ('V091','V092')
				Then 'Manipulation under anaesthesia of fractured nose (as sole procedure)'

		when (Treatment_Function_Code in ('120','215') or Main_Specialty_Code = '120') and
			 LEFT(Primary_Procedure_Code,3) = 'D15'
				Then 'Myringotomy ± insertion of tube, suction clearance'

		when (Treatment_Function_Code in ('120','215') or Main_Specialty_Code = '120') and
			 LEFT(Primary_Procedure_Code,4) = 'E051'
				Then 'Nasal septum cauterisation (and bilateral)'

		when (Treatment_Function_Code in ('120','215') or Main_Specialty_Code = '120') and
			 LEFT(Primary_Procedure_Code,3) = 'D16'
				Then 'Ossiculoplasty'

		when (Treatment_Function_Code in ('120','215') or Main_Specialty_Code = '120') and
			 LEFT(Primary_Procedure_Code,4) = 'D033'
				Then 'Pinnaplasty (including bilateral)'

		when (Treatment_Function_Code in ('120','215') or Main_Specialty_Code = '120') and
			 LEFT(Primary_Procedure_Code,4) = 'D203'
				Then 'Removal of ventilation device'

		when (Treatment_Function_Code in ('120','215') or Main_Specialty_Code = '120') and
			 LEFT(Primary_Procedure_Code,3) = 'E24'
				Then 'Therapeutic endoscopic operations on pharynx'


---- GYNAECOLOGY
		when (Treatment_Function_Code in ('502','503') or Main_Specialty_Code in ('500','502')) and 
			SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('Q162','Q163','Q164','Q165','Q166','Q176','Q177'))
				Then 'HVLC Endometrial ablation' -- as per GIRFT HVLC Pathways – Code Group Recipes and GIRFT_Metadata_Gynaecology files

		when (Treatment_Function_Code in ('502','503') or Main_Specialty_Code in ('500','502')) and 
			(left(Primary_Procedure_Code,3) = 'Q18' or left(Primary_Procedure_Code,4) in ('Q161','Q167','Q168','Q169','Q171','Q172','Q173','Q174','Q175','Q178','Q179')) and 
			SK_EncounterID not in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('Y751','Y752','Y755','Q413')) and
			(SK_EncounterID not in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_diag_vw where left(diag,3) in ('C51','C52','C53','C54','C55','C56','C57','D06') or left(diag,4) in ('C796','D070','D071','D072,D073')))
				Then 'HVLC Hysteroscopy' -- as per GIRFT HVLC Pathways – Code Group Recipes and GIRFT_Metadata_Gynaecology files

		when (Treatment_Function_Code in ('502','503') or Main_Specialty_Code in ('500','502')) and 
			(SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,3) in ('Q07','Q08')) and
 			 SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('Y751','Y752'))) and
			 (SK_EncounterID not in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_diag_vw where (left(diag,3) in ('C51','C52','C53','C54','C55','C56','C57','D06')) or left(diag,4) in ('C796','D070','D071','D072,D073')))
				Then 'HVLC Laparoscopic hysterectomy' -- as per GIRFT HVLC Pathways – Code Group Recipes and GIRFT_Metadata_Gynaecology files
					
		when (Treatment_Function_Code in ('502','503') or Main_Specialty_Code in ('500','502')) and 
			 (left(Primary_Procedure_Code,4) in ('Q201','Q362','Q381','Q382','Q388','Q389','Q413','Q521','Q522') or left(Primary_Procedure_Code,3) In ('Q39','Q49','Q50','T42')) and -- 08/09/2022 Correction. T42 was in (opcs,4) rather than opcs,3
			 SK_EncounterID not in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'Q383') and 
			 SK_EncounterID not in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_diag_vw where left(diag,3) in ('C51','C52','C53','C54','C55','C56','C57','D06') or left(diag,4) in ('C796','D070','D071','D072,D073'))
				Then 'HVLC Operative laparoscopy' -- as per GIRFT HVLC Pathways – Code Group Recipes and GIRFT_Metadata_Gynaecology files
			 
		when (Treatment_Function_Code in ('502','503') or Main_Specialty_Code in ('500','502')) and 
			  SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,3) in ('Q08','P22','P23','P24')) and
			  (SK_EncounterID not in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_diag_vw where (left(diag,3) in ('C51','C52','C53','C54','C55','C56','C57','D06')) or left(diag,4) in ('C796','D070','D071','D072,D073')))
				Then 'HVLC Vaginal hysterectomy and/or vaginal wall repair' -- as per GIRFT HVLC Pathways – Code Group Recipes and GIRFT_Metadata_Gynaecology files
		  																    -- In Stephanie's list, these 2 procedures are separate, therefore, created a Sub category
																			-- Q08 is also being used for HVLC Laparoscopic hysterectomy

		when (Treatment_Function_Code in ('502','503') or Main_Specialty_Code in ('500','502')) and 
			 left(Primary_Procedure_Code,4) in ('P273','P278','P279','Q554')
				Then 'Colposcopy (± biopsy)' 

		when (Treatment_Function_Code in ('502','503') or Main_Specialty_Code in ('500','502')) and 
			 left(Primary_Procedure_Code,3) = 'Q03'
				Then 'Cone biopsy of cervix uteri (including laser)'

		when (Treatment_Function_Code in ('502','503') or Main_Specialty_Code in ('500','502')) and 
			 (left(Primary_Procedure_Code,4) in ('Q013','Q014') or left(Primary_Procedure_Code,3) = 'Q02')
				Then 'Destruction of lesion of cervix uteri (including loop diathermy and laser)'

		when (Treatment_Function_Code in ('502','503') or Main_Specialty_Code in ('500','502')) and 
			 left(Primary_Procedure_Code,3) in ('Q35','Q36')
				Then 'Female Sterilisation' -- OPCS code Q362 is also being used for HVLC Operative laparoscopy

		when (Treatment_Function_Code in ('502','503') or Main_Specialty_Code in ('500','502')) and 
			 (left(Primary_Procedure_Code,3) in ('Q22','Q23','Q24','Q25') and SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'Y752'))
				Then 'Laparoscopic oophorectomy and salpingectomy (including bilateral)'

		when (Treatment_Function_Code in ('502','503') or Main_Specialty_Code in ('500','502')) and 
			 left(Primary_Procedure_Code,4) = 'P032'
				Then 'Marsupialisation of Bartholin cyst'

		when (Treatment_Function_Code in ('502','503') or Main_Specialty_Code in ('500','502')) and 
			 left(Primary_Procedure_Code,3) = 'Q09'
				Then 'Myomectomy (including laparoscopically)'

		when (Treatment_Function_Code in ('502','503') or Main_Specialty_Code in ('500','502')) and 
			 left(Primary_Procedure_Code,4) in ('M533','M536','M538')
				Then 'Operations to manage female incontinence'

		when (Treatment_Function_Code in ('502','503') or Main_Specialty_Code in ('500','502')) and 
			 left(Primary_Procedure_Code,4) in ('M533','M536','M538')
				Then 'Operations to manage female incontinence'

		when (Treatment_Function_Code in ('502','503') or Main_Specialty_Code in ('500','502')) and 
			 left(Primary_Procedure_Code,4) in ('Q101','Q102','Q111','Q112','Q113','Q115','Q116') and
			 SK_EncounterID in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_diag_vw where left(diag,3) in ('O04','O05','O06'))
				Then 'Termination of Pregnancy (medical abortion)'


---- OPHTHALMOLOGY
		when -- (Treatment_Function_Code = '130' or Main_Specialty_Code = '130' and 
			  (SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,3) in ('C71','C73','C74')) and
 			  SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('C751','C754','C758','C759'))
			  ) and
			  SK_EncounterID not in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('C647','C776','C792','C793','C795','C796','C797','C801','C802','C803','C804','C805','C806','C808','C809')) and -- 10/08/2022 changed from 'AND' to 'OR' as output or numbers are low
			 SK_EncounterID not in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_diag_vw where left(diag,3) in ('F00','F01','F02','F03','G30','F70','F71','F72','F73','F78','F79')) and
			  SK_EncounterID not in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_diag_vw where left(diag,4) in ('F051','G310','G311','H200','H201','H202','H208','H209','H220','H221','H300','H301','H302','H308','H309','H320'))
				Then 'HVLC Low complexity cataract surgery' -- as per GIRFT HVLC Pathways – Code Group Recipes 

		when (left(Primary_Procedure_Code,3) in ('C71','C72','C73','C74','C75') or left(Primary_Procedure_Code,4) = 'C771') and left(Primary_Procedure_Code,4) <> 'C753'
				Then 'Extraction of cataract ± implant' -- most of the OPCS codes are also used for HVLC Low complexity cataract surgery

		when left(Primary_Procedure_Code,4) in ('C101','C106')
				Then 'Biopsy / cauterisation/curettage of lesion of eyelid'

		when left(Primary_Procedure_Code,3) = 'C39' or left(Primary_Procedure_Code,3) = 'C432'
				Then 'Biopsy / sampling of conjunctival lesion'

		when left(Primary_Procedure_Code,3) = 'C13' 
				Then 'Blepharoplasty'

		when left(Primary_Procedure_Code,4) in ('C151','C154')
				Then 'Correction of ectropion'

		when left(Primary_Procedure_Code,4) in ('C152','C155')
				Then 'Correction of entropion'

		when left(Primary_Procedure_Code,3) = 'C18'
				Then 'Correction of ptosis of eyelid'

		when left(Primary_Procedure_Code,3) in ('C31','C32','C33','C34','C35')
				Then 'Correction of squint'

		when left(Primary_Procedure_Code,4) in ('C251','C252','C253','C254')
				Then 'Dacryocystorhinostomy (including insertion of tube)'

		when left(Primary_Procedure_Code,4) in ('C121','C126','C128')
				Then 'Excision lesion of eyelid'

		when left(Primary_Procedure_Code,4) = 'C111'
				Then 'Excision of lesion of canthus'

		when left(Primary_Procedure_Code,4) IN ('C101','C106')
				Then 'Excision of lesion of eyebrow'

		when left(Primary_Procedure_Code,4) = 'C623'
				Then 'Laser iridotomy'

		when left(Primary_Procedure_Code,4) = 'C664'
				Then 'Laser photocoagulation of ciliary body'

		when left(Primary_Procedure_Code,4) = 'C601'
				Then 'Surgical trabeculectomy or other penetrating glaucoma procedures'

		when left(Primary_Procedure_Code,4) in ('C791','C792')
				Then 'Vitrectomy using pars plana approach'


---- UROLOGY
		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,4) in ('M651','M653','M654','M655','M656','M658','M659','M662','M681','M683','M688','M689')
				Then 'HVLC Bladder outflow obstruction' -- as per GIRFT HVLC Pathways – Code Group Recipes  and GIRFT_Metadata_Urology files
														-- This procedure has the same procedure codes as Transurethral resection of prostate (TURP) and Laser destruction of prostate. They are included in the Sub Category
		
		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,4) in ('M451','M452','M453','M454','M455','M458','M459','M441','M442','M763','M764','M792','M814') 
				Then 'HVLC Cystoscopy plus' -- as per GIRFT.

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,4) in ('N303','N284','N113','N111','N112','N114','N118','N115','N119','N116','M731','N092','N132','N082','N099','N089','N093','N098','N083','N088','N094','N081','N084','N091','N321','T193','N191','N198','N199')
				Then 'HVLC Minor peno-scrotal surgery' -- as per GIRFT.

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,4) = 'M421'
				Then 'HVLC Bladder tumour resection (TURBT)' -- as per GIRFT.

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,4) in ('M071','M072','M078','M079','M271','M272','M273','M274','M275','M277','M278','M279','M306','M281','M282','M283','M288','M289','M292','M293','M295')
				Then 'HVLC Ureteroscopy and stent management' -- Some of the opcs codes for this procedures are the same as the ones used for Ureteroscopic destruction of calculus in ureter and Endoscopic insertion of prosthesis into ureter.
															  -- Ureteroscopic destruction of calculus in ureter and Endoscopic insertion of prosthesis into ureter are included in the Sub Category

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,3) = 'N11'
				Then 'Correction of hydrocele' -- This code is also being used for HVLC Minor peno-scrotal surgery

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,4) = 'M382'
				Then 'Cystostomy and insertion of suprapubic tube into bladder'

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,3) = 'M45'
				Then 'Diagnostic endoscopic examination of bladder (including any biopsy)' -- code is also used for HVLC Cystoscopy plus

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,3) = 'M77'
				Then 'Endoscopic examination of urethra ± biopsy' 

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,3) in ('M441','M442')
				Then 'Endoscopic extraction of calculus of bladder'  -- codes also used for HVLC Cystoscopy plus

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,3) =  'M662'
				Then 'Endoscopic incision of outlet of male bladder'  -- codes also used for HVLC Bladder outflow obstruction

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,3) in ('M292','M295','M274')
				Then 'Endoscopic insertion of prosthesis into ureter'  -- codes also used for HVLC Ureteroscopy and stent management

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,3) = 'M683'
				Then 'Endoscopic insertion of prosthesis to compress lobe of prostate'  -- codes also used for HVLC Bladder outflow obstruction

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,3) = 'M093'
				Then 'Endoscopic laser fragmentation of calculus of kidney'

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,3) in ('M651','M652','M653','M658') and 
		SK_EncounterID not in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('M654','M659'))
				Then 'Endoscopic resection of prostate (TUR)' -- some codes are also used for HVLC Bladder outflow obstruction

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,3) = 'M42'
				Then 'Endoscopic resection / destruction of lesion of bladder' -- code M421 is used for HVLC Bladder tumour resection (TURBT)

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,3) = 'N15'
				Then 'Excision of epididymal lesion' 

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,3) = 'N27'
				Then 'Excision of lesion of penis' 

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,4) = 'N064' or left(Primary_Procedure_Code,3) = 'N07'
				Then 'Excision of lesion of testis' 

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,4) = 'N284'
				Then 'Frenuloplasty of penis' -- code is also used for HVLC Minor peno-scrotal surgery

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,3) = 'N19'
				Then 'Operation(s) on varicocele' -- code is also used for HVLC Minor peno-scrotal surgery

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,3) = 'N30'
				Then 'Operations on foreskin - circumcision, division of adhesions' -- code is also used for HVLC Minor peno-scrotal surgery

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,3) = 'M81'
				Then 'Operations on urethral orifice' -- code is also used for HVLC Cystoscopy plus

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,4) = 'M763'
				Then 'Optical Urethrotomy' -- code is also used for HVLC Cystoscopy plus

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,4) in ('M278','M291','M294','M298','M299') or left(Primary_Procedure_Code,3) = 'M28'
				Then 'Other endoscopic procedures on ureter' -- codes are also used for HVLC Ureteroscopy and stent management

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,4) in ('M293','M336','M275')
				Then 'Removal of prosthesis from ureter' -- codes are also used for HVLC Ureteroscopy and stent management

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		(left(Primary_Procedure_Code,4) = 'M654' or SK_EncounterID not in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'M653')) and
		SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('Y083','Y084'))
				Then 'Resection of prostate by laser' -- codes are also used for HVLC Bladder outflow obstruction' 

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,4) in ('M271','M272','M273')
				Then 'Ureteroscopic extraction of calculus of ureter' -- codes are also used for HVLC Ureteroscopy and stent management

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,3) = 'N17'
				Then 'Vasectomy' 

---- ORTHOPAEDICS
		when --(Treatment_Function_Code in ('110','214') or Main_Specialty_Code = '110') and
		(left(Primary_Procedure_Code,4) in ('W723','W742','W752','W748','W758','W841','W842') and SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('Z845','Z846')))
				Then 'HVLC Anterior cruciate ligament reconstruction'

		when --(Treatment_Function_Code in ('110','214') or Main_Specialty_Code = '110') and
		SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('W791','W792','W151','W152','W153'))
				Then 'HVLC Bunions'

		when --(Treatment_Function_Code in ('110','214') or Main_Specialty_Code = '110') and
		(left(Primary_Procedure_Code,4) in ('W781','T791','O291','T794') and SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'Y767')) 
		or
		(left(Primary_Procedure_Code,4) = 'W844' and SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('Z682','Z812','Z813','Z814','Z891'))) 
		or
		(left(Primary_Procedure_Code,4) in ('T645','T702') and SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('Z544','Y767'))) -- T702 is also used for Lengthening / shortening of tendon(s)
		or 
		(left(Primary_Procedure_Code,4) = ' W784' and SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('Z812','Z813','Z814','Z891','Z681','Z682','Z683','Z684','Z685','Z688','Z689','Z691','Z693')))
				Then 'HVLC Therapeutic shoulder arthroscopy'

		when --(Treatment_Function_Code in ('110','214') or Main_Specialty_Code = '110') and
		(left(Primary_Procedure_Code,4) in ('W371','W379','W381','W389','W931','W939','W391','W399','W941','W949','W951','W959') or 
		(left(Primary_Procedure_Code,4) in ('W521','W529','W531','W539','W541','W549') and SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'Z843'))) and
		(SK_EncounterID not in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('Y713','Y716','Y717','W051','W052','W053','W054','W055','W058','W059')) or 
		 SK_EncounterID not in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_diag_vw where left(diag,4) = 'C402'))
				Then 'HVLC Total hip replacement'

		when --(Treatment_Function_Code in ('110','214') or Main_Specialty_Code = '110') and
		left(Primary_Procedure_Code,4) in ('O181','O189','W401','W409','W411','W419','W421','W429','O188','W408','W418','W428') and
		(SK_EncounterID not in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('Y713','Y716','Y717','Y031','Y032','Y033','Y034','Y035','Y036','Y037','Y038','Y039','W051','W052','W053','W054','W055','W058','W059')) or 
		left(Primary_Diagnosis_Code,4) not in ('C400','C401','C402','C403','C408','C409','C492') or
		SK_EncounterID not in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_diag_vw where left(diag,4) in  ('M932','M939','Q774')))
				Then 'HVLC Total knee replacement'

		when --(Treatment_Function_Code in ('110','214') or Main_Specialty_Code = '110') and
		(left(Primary_Procedure_Code,4) = 'W581' and SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('Z845','Z846','O132','Z844'))) -- 24/02/2023 added Z844 as this is included in the model hospital
				Then 'HVLC Uni knee replacement' -- in the Model Hospital, opcs code O132 is not included but it is in the 'Orthopaedic-Elective_2021-12-23_Coding_HVLC-pathway-coding-recipes' document

		when --(Treatment_Function_Code in ('110','214') or Main_Specialty_Code = '110') and
		left(Primary_Procedure_Code,4) = 'A651' 
				Then 'Carpal tunnel release'

		when left(Primary_Procedure_Code,4) in ('T521','T522','T541')
				Then 'Dupuytrens fasciectomy'

		when left(Primary_Procedure_Code,4) in  ('W903','W904','W923','W924') or left(Primary_Procedure_Code,3) = 'W91'
				Then 'Examination / manipulation of joint under anaesthetic ± injection'

		when left(Primary_Procedure_Code,3) in  ('T59','T60')
				Then 'Excision of ganglion'

		when left(Primary_Procedure_Code,4) in ('A611','A612','A614','A618','A619')
				Then 'Excision of lesion of peripheral nerve'

		when left(Primary_Procedure_Code,3) in ('S64','S68','S70')
				Then 'Excision of nail / nailbed'

		when left(Primary_Procedure_Code,3) = 'T72' or left(Primary_Procedure_Code,4) = 'T711'
				Then 'Exploration of sheath of tendon (eg trigger finger)'

		when left(Primary_Procedure_Code,3) = 'T70'
				Then 'Lengthening / shortening of tendon(s)'

		when left(Primary_Procedure_Code,4) = 'W262'
				Then 'MUA Fracture and application of plaster cast'

		when left(Primary_Procedure_Code,4) = 'A671' or left(Primary_Procedure_Code,3) = 'A68'
				Then 'Neurolysis and transposition of peripheral nerve eg ulnar nerve at elbow'

		when left(Primary_Procedure_Code,4) = 'W205'
				Then 'Primary reduction and open fixation of ankle'

		when left(Primary_Procedure_Code,4) = 'W201' and 
		(SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,3) = 'Z70') or SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'O311'))
				Then 'Primary reduction and open fixation of wrist'

		when left(Primary_Procedure_Code,3) in ('S44','S45')
				Then 'Removal of foreign body from skin'

		when left(Primary_Procedure_Code,4) = 'W283'
				Then 'Removal of internal fixation from bone/joint, excluding K-wires'

		when left(Primary_Procedure_Code,4) in  ('T671','T672','T676')
				Then 'Repair of hand or wrist tendon'



---- GENERAL SURGERY
		-- The following HVLC procedures are in the N:\NELCSU\NCLMTFS\_DATA\Ad-Hoc\Day Case Rates\GIRFT Coding files\General-surgery_2021-12-23_Coding_HVLC-pathway-coding-recipes.pdf 
		when (left(Primary_Procedure_Code,4) in ('J181','J183') and SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'Y752')) and 
		 SK_EncounterID not in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'J182')
				Then 'HVLC Laparoscopic cholecystectomy' -- as per GIRFT - consistent to BADS

		when SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('T201','T202','T203','T204','T208','T209')) and -- 06/09/2022 Error in the script. Changed from Primary to Any levels as per GIRFT
			SK_EncounterID not in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('Y713','Y716','Y717')) and -- excludes Revision operations
			SK_EncounterID not in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_diag_vw where left(diag,3) = 'C56' or left(diag,4) = 'C570') -- excludes Ovarian cancer and Fallopian cancer
				Then 'HVLC Primary inguinal hernia repair'

		when left(Primary_Procedure_Code,3) = 'T24' and left(Primary_Procedure_Code,4) <> 'T244'
				Then 'HVLC Para-umbilical hernia' -- as per GIRFT - consistent to BADS
		
		when left(Primary_Procedure_Code,4) in ('G753','H154')
				Then 'Closure iliostomy'

		when (left(Primary_Procedure_Code,3) in ('J09','T43') or left(Primary_Procedure_Code,4) in ('J738','J739','T518','J519'))
			 and SK_EncounterID not in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('J731','J531'))
				Then 'Diagnostic laparoscopy'

		when left(Primary_Procedure_Code,3) = 'T87'
			 and SK_EncounterID not in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('T874','T875','T876'))
				Then 'Excision / biopsy of lymph node for diagnosis (cervical, inguinal, axillary)'

		when left(Primary_Procedure_Code,3) in ('H48','H49','H561')
				Then 'Excision / destruction of lesion of anus'

		when left(Primary_Procedure_Code,3) = 'H564' and SK_EncounterID not in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,3) = 'H50')
				Then 'Excision / treatment of anal fissure'

		when left(Primary_Procedure_Code,4) in ('H401','H402','H403','H412','H413')
				Then 'Transanal excision of lesion of anus'

		when left(Primary_Procedure_Code,4) in ('H511','H513')
				Then 'Haemorrhoidectomy'

		when left(Primary_Procedure_Code,4) in ('H523','H524')
				Then 'Injection or banding of haemorrhoids'

		when SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'G243') and SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'Y752')
				Then 'Laparoscopic repair of hiatus hernia with anti-reflux procedure (eg fundoplication)' -- as per BADS definition in the GIRFT_Metadata_GenS file
						
		when left(Primary_Procedure_Code,3) = 'T22' and left(Primary_Diagnosis_Code,3) = 'K41'
				Then 'Primary repair of femoral hernia' -- as per GIRFT_Metadata_GenS file

		when left(Primary_Procedure_Code,3) = 'T25' and SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'Y752')
				Then 'Laparoscopic repair of incisional hernia' 

		when left(Primary_Procedure_Code,3) = 'T21' 
				Then 'Repair of recurrent inguinal hernia'

		when SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'G303') and
				SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'Y752')
				Then 'Laparoscopic gastric banding'

		when (left(Primary_Procedure_Code,3) = 'H59' or left(Primary_Procedure_Code,4) in ('H600','H601','H602','H603','H608','H609')) and
				SK_EncounterID not in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'H604')
				Then 'Pilonidal sinus surgery - laying open or suture/ skin graft'

		when left(Primary_Procedure_Code,4) in ('H425','H426','H428','H429')
				Then 'Repair of rectal mucosal prolapse'

		when left(Primary_Procedure_Code,4) in ('H551','H552','H553','H554') and SK_EncounterID not in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'H555')
				Then 'Treatment of anal fistula with seton suture'

---- SPINAL
		when --Treatment_Function_Code in ('110','150','191','812')  and
		(SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('V221','V222','V294','V295','V361')) or
		(SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('V368','V369')) and SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('Z673','Z991')))) and
		(SK_EncounterID not in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('V224','V225','V226','V231','V232','V233','V234','V235','V236','V237','V238','V239','V301','V302','V303','V304','V305','V306','V308','V309','V371','V373','V374','V375','V376','V377','V391','V553')) 
		or SK_EncounterID not in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('V41','V42')))
				Then 'HVLC Cervical spine decompression / fusion'

		when --Treatment_Function_Code in ('110','150','191','812')  and
		(SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('V252','V254','V255','V256','V258','V259','V671','V672','V331','V332','V337','V338','V339')) or 
		(SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('V351','V358','V359')) and
		SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('Z063','Z073','Z665','Z675','Z676','Z993')))) and 
		SK_EncounterID not in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('V262','V264','V265','V266','V268','V269','V681','V682','V688','V689','V341','V342','V347','V348','V349','V553','V251','V253','V382','V383','V384','V385','V386','V404')) 
				Then 'HVLC Lumbar Decompression / Discectomy'

		when --Treatment_Function_Code in ('110','150','191','812')  and
		left(Primary_Procedure_Code,4) in ('A521','A522','A528','A529','A577') or 
		(left(Primary_Procedure_Code,4) = 'A735' and SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,3) = 'Z07'))
				Then 'HVLC Lumbar nerve root block / therapeutic epidural injection'

		when --Treatment_Function_Code in ('110','150','191','812')  and
		left(Primary_Procedure_Code,4) = 'V544'
				Then 'HVLC Lumbar medial branch block/facet joint injections'

		when --Treatment_Function_Code in ('110','150','191','812')  and
		SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('V251','V253','V382','V383','V384','V385','V386','V404')) and
		SK_EncounterID not in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('V261','V263','V267','V343','V344','V345','V346','V393','V394','V395','V396','V397','V262','V264','V265','V266','V268','V269','V681','V682','V688','V689','V553'))
				Then 'HVLC 1 or 2 Level Posterior Fusion'

---- HEAD & NECK
		when left(Primary_Procedure_Code,4) = 'F121'
				Then 'Apicectomy'

		when left(Primary_Procedure_Code,4) in ('T861','T871','T872')
				Then 'Biopsy / sampling of cervical lymph nodes'

		when left(Primary_Procedure_Code,3)  = 'F18'
				Then 'Enucleation of cyst of jaw'

		when left(Primary_Procedure_Code,3)  = 'F38'
				Then 'Excision / destruction of lesion of mouth'

		when left(Primary_Procedure_Code,3)  = 'F02'
				Then 'Excision of lesion of lip'

		when left(Primary_Procedure_Code,4) in ('B144','B145','B148','B149') and
		SK_EncounterID not in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('B141','B142','B143'))
				Then 'Excision of lesion of parathyroids'

		when left(Primary_Procedure_Code,4) in ('F441','F442','F443') and
		SK_EncounterID not in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('F448','F449'))
				Then 'Excision of parotid gland'

		when left(Primary_Procedure_Code,4) in ('F444','F445','F452','F453')
				Then 'Excision of submandibular or sublingual gland'

		when left(Primary_Procedure_Code,3) = 'F145'
				Then 'Exposure of buried teeth'

		when left(Primary_Procedure_Code,4) in ('B083','B084','B085','B086')
				Then 'Hemithyroidectomy, lobectomy, partial thyroidectomy'

		when left(Primary_Procedure_Code,4) = 'V093'
				Then 'Reduction of fracture of zygomatic complex of bones'

		when left(Primary_Procedure_Code,3) = 'V15'
				Then 'Reduction of fractured mandible'

		when left(Primary_Procedure_Code,3) = 'F09'
				Then 'Surgical removal of impacted / buried tooth / teeth'

		when left(Primary_Procedure_Code,4) in ('B081','B082','B088','B089' )
				Then 'Total / subtotal thyroidectomy'

---- MEDICAL
		when left(Primary_Procedure_Code,4) = 'W365'
				Then 'Bone marrow biopsy'

		when left(Primary_Procedure_Code,4) in ('X501','X502')
				Then 'Elective cardioversion'

		when left(Primary_Procedure_Code,3) in ('J38','J39','J40','J41','J42','J43','J44')
				Then 'ERCP'

		when left(Primary_Procedure_Code,3) in ('K60','K61') and SK_EncounterID not in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('K602','K604','K612','K614'))
				Then 'Implantation of cardiac pacemaker'

		when left(Primary_Procedure_Code,4) in ('J132','J141')
				Then 'Liver biopsy'

		when left(Primary_Procedure_Code,4) = 'M131'
				Then 'Renal biopsy'

---- BREAST SURGERY
		--when left(Primary_Procedure_Code,4) = 'B286'
		--		Then 'Excision of accessory breast tissue'

		--when (left(Primary_Procedure_Code,4) = 'B281' and ((SK_EncounterID in(select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) =  'T873' and 
		--SK_EncounterID in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) =  'O142') 
		--or SK_EncounterID in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'T862' 
		--or SK_EncounterID in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'T852')) 
		--or (left(Primary_Procedure_Code,4) = 'B282' and ((SK_EncounterID in(select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'T873' and 
		--SK_EncounterID in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'O142') 
		--or SK_EncounterID in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'T862' 
		--or SK_EncounterID in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'T852')) 
		--or (left(Primary_Procedure_Code,4) = 'B283' and ((SK_EncounterID in(select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'T873' and 
		--SK_EncounterID in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'O142') 
		--or SK_EncounterID in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'T862' 
		--or SK_EncounterID in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'T852')) 
		--or (left(Primary_Procedure_Code,4) = 'B285' and ((SK_EncounterID in(select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'T873' and 
		--SK_EncounterID in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'O142') 
		--or SK_EncounterID in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'T862' 
		--or SK_EncounterID in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'T852')) 
		--or (left(Primary_Procedure_Code,4) = 'B287' and ((SK_EncounterID in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'T873' and 
		--SK_EncounterID in(select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'O142') 
		--or SK_EncounterID in(select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'T862' 
		--or SK_EncounterID in(select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'T852')) 
		--or (left(Primary_Procedure_Code,4) = 'B288' and ((SK_EncounterID in(select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'T873' and 
		--SK_EncounterID in(select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'O142') 
		--or SK_EncounterID in(select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'T862' 
		--or SK_EncounterID in(select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'T852')) 
		--or (left(Primary_Procedure_Code,4) = 'B289' and ((SK_EncounterID in(select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'T873' and 
		--SK_EncounterID in(select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'O142') 
		--or SK_EncounterID in(select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'T862' 
		--or SK_EncounterID in(select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'T852'))
		--		Then 'Excision of breast with sentinel lymph node biopsy, axillary sample or axillary clearance'
					Else 'Other'
						End as [Procedures]

---- EMERGENCY SURGERY Added on 14-03-2023
		-- TRICKY AS DENOMINATOR INCLUDES NEL
		--when left(Primary_Procedure_Code,4) in ('H012','H013')
		--		Then 'Appendicectomy (including laparoscopic)'

-- Created a Sub Category for those procedures where OPCS codes overlap with each other or with HVLC
,case	

------ENT
		when (Treatment_Function_Code in ('120','215') or Main_Specialty_Code = '120') and
		left(Primary_Procedure_Code,4) in ('D141','D142','D144','D148','D149') and
		SK_EncounterID not in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'D143')
			Then 'Tympanoplasty' -- as per BADS in the GIRFT_Metadata_ENT file
	 
		when (Treatment_Function_Code in ('120','215') or Main_Specialty_Code = '120') and
		left(Primary_Procedure_Code,4) = 'E036' --- code is also used for 'HVLC Septoplasty and Turbinate'
			Then 'Septoplasty of nose'

	-- Added on 19-01-2023 as part of a piece of work where procedures can be done as a DC. These will be included in the dashboard as part of the DC rate monitoring report
		when (Treatment_Function_Code in ('120','215') or Main_Specialty_Code = '120') and
			 LEFT(Primary_Procedure_Code,4) = 'E142' -- code is also used for 'HVLC Endoscopic Sinus Surgery'
				Then 'FESS Endoscopic uncinectomy, anterior and posterior ethmoidectomy'

		when (Treatment_Function_Code in ('120','215') or Main_Specialty_Code = '120') and
			 LEFT(Primary_Procedure_Code,4) = 'E133' -- code is also used for 'HVLC Endoscopic Sinus Surgery'
				Then 'Intranasal antrostomy (including endoscopic)' 

		when (Treatment_Function_Code in ('120','215') or Main_Specialty_Code = '120') and
			 LEFT(Primary_Procedure_Code,3) = 'E04' -- codes are also used for HVLC Septoplasty and Turbinate
				Then 'Operations on turbinates of nose (laser, diathermy, out fracture etc)' 

------- GYNAE
		when (Treatment_Function_Code in ('502','503') or Main_Specialty_Code in ('500','502')) and 
		left(Primary_Procedure_Code,3) = 'Q08'
			Then 'Vaginal hysterectomy (including laparoscopically assisted)'  -- OPCS code is also used for HVLC Laparoscopic hysterectomy and HVLC Vaginal hysterectomy and/or vaginal wall repair
		
		when (Treatment_Function_Code in ('502','503') or Main_Specialty_Code in ('500','502')) and 
		left(Primary_Procedure_Code,4) = 'P231'
			Then 'Anterior or posterior vaginal repair' -- Also called Anterior and posterior colporrhaphy in the Model Hospital
														-- the OPCS code is also used for HVLC Vaginal hysterectomy and/or vaginal wall repair

		when (Treatment_Function_Code in ('502','503') or Main_Specialty_Code in ('500','502')) and 
		left(Primary_Procedure_Code,4) in ('P233','P237')
			Then 'Posterior colporrhaphy' -- the OPCS codes are also used for HVLC Vaginal hysterectomy and/or vaginal wall repair

		when (Treatment_Function_Code in ('502','503') or Main_Specialty_Code in ('500','502')) and 
		(left(Primary_Procedure_Code,3) = 'Q18' or left(Primary_Procedure_Code,4) in ('Q202','Q205','Q208','Q209'))
			Then 'Endometrial biopsy / aspiration + hysteroscopy' -- OPCS code Q18 is also being used for HVLC Hysteroscopy

		when (Treatment_Function_Code in ('502','503') or Main_Specialty_Code in ('500','502')) and 
		(left(Primary_Procedure_Code,4) in ('Q074','Q075') and SK_EncounterID in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'Y752'))
			Then 'Laparoscopic total/subtotal abdominal hysterectomy' -- Q074 is also used for HVLC Laparoscopic hysterectomy

		when (Treatment_Function_Code in ('502','503') or Main_Specialty_Code in ('500','502')) and 
		left(Primary_Procedure_Code,3) in ('Q16','Q17') 
			Then 'Therapeutic endoscopic operations on uterus (including endometrial ablation)' -- The OPCS codes are also used for HVLC Endometrial ablation & HVLC Hysteroscopy

		when (Treatment_Function_Code in ('502','503') or Main_Specialty_Code in ('500','502')) and 
			 (left(Primary_Procedure_Code,4) in ('Q201','Q362') or left(Primary_Procedure_Code,3) In ('Q38','Q39','Q49','Q50','T42')) and 
			 SK_EncounterID not in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('Q383','Q521','Q522'))
				Then 'Therapeutic laparoscopic procedures including laser, diathermy and destruction eg endometriosis, adhesiolysis, tubal surgery' -- codeas are also used for HVLC Operative laparoscopy

------ UROLOGY
		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,4) in ('M651','M652','M653','M658')  and
		SK_EncounterID not in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('M654','M659'))
				Then 'Transurethral resection of prostate (TURP)' -- as per GIRFT_Metadata_Urology file

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		(left(Primary_Procedure_Code,4) in ('M654','M653') and SK_EncounterID in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_diag_vw where left(diag,4) = 'Y083')) or
		(left(Primary_Procedure_Code,4) = 'M654' and SK_EncounterID in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_diag_vw where left(diag,4) = 'Y084'))
				Then 'Laser destruction of prostate' -- as per BADS definition in the GIRFT_Metadata_Urology file

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		left(Primary_Procedure_Code,4) in ('M271','M272','M273')
				Then 'Ureteroscopic destruction of calculus in ureter' -- as per BADS in Model Hospital. Name does not exists in Model Hospital or other GIRFT documents. 
																	   -- Is this the same as Ureteroscopic extraction of calculus of ureter (MH) or Ureteroscopy for stones on ureter (GIRFT_Metadata_Urology file)?
																	   -- Used the opcs codes for Ureteroscopic extraction of calculus of ureter
																	   
		-- 28/11/2022 Added as part of the deep dive for the GIRFT visit. Please note that same opcs codes are used for HVLC Bladder outflow obstruction
		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		(SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('M651','M653','M655','M662','M654')) or SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,3) = 'M68')) and
		gender_code = 1
				Then 'Male bladder outflow surgery' 

		when (Treatment_Function_Code in ('101','211') or Main_Specialty_Code = '101') and
		LEFT(Primary_Procedure_Code,4) = 'E081' and -- code is also used for 'HVLC Endoscopic Sinus Surgery'
		SK_EncounterID not in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('E082','E088','E089'))
				Then 'Polypectomy of internal nose' 

------ ORTHOPAEDIC
		when --(Treatment_Function_Code in ('110','214') or Main_Specialty_Code = '110') and
		left(Primary_Procedure_Code,3) = 'W82' 
		or 
		(left(Primary_Procedure_Code,3) in ('W83','W84') and SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'Z846'))
		or
		left(Primary_Procedure_Code,3) in ('W85','W87','W88')
				Then 'Arthroscopy of knee (including meniscectomy, meniscal or other repair)' -- some codes are also being used for HVLC Anterior cruciate ligament reconstruction and  HVLC Therapeutic shoulder arthroscopy

		when left(Primary_Procedure_Code,3) = 'W88' and SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'Z814')
				Then 'Diagnostic arthroscopic examination of shoulder joint'

		when --(Treatment_Function_Code in ('110','214') or Main_Specialty_Code = '110') and
		(left(Primary_Procedure_Code,4) in ('W848','T791')  
		or
		(left(Primary_Procedure_Code,4) = 'W844' and SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'Z682' )) 
		or
		(left(Primary_Procedure_Code,4) in ('W771','W778')  and SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) = 'Z542')) 
		or 
		(left(Primary_Procedure_Code,4) = 'W778' and SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4)  = 'Z542')))
		and SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4)  = 'O291')
				Then 'Therapeutic arthroscopy of shoulder - subacromial decompression, cuff repair' -- some codes are used for HVLC Therapeutic shoulder arthroscopy AND Diagnostic arthroscopic examination of shoulder joint

		when --(Treatment_Function_Code in ('110','214') or Main_Specialty_Code = '110') and
		left(Primary_Procedure_Code,4) = 'W742'
				Then 'Autograft anterior cruciate ligament reconstruction' --the opcs code is also used for HVLC Anterior cruciate ligament reconstruction

		when --(Treatment_Function_Code in ('110','214') or Main_Specialty_Code = '110') and
		left(Primary_Procedure_Code,3)  in ('W79','W59') or left(Primary_Procedure_Code,4)  in  ('W151','W152','W153')
				Then 'Bunion operations with or without internal fixation and soft tissue correction' -- some codes are used for HVLC Bunions

		when --(Treatment_Function_Code in ('110','214') or Main_Specialty_Code = '110') and
		SK_EncounterID in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('V337','V338','V339')) and
		SK_EncounterID not in (select sk_encounterid from [Data_Lab_NCL].dbo.ip_opcs_vw where left(opcs,4) in ('V347','V438')) 
				Then 'Posterior excision of lumbar disc prolapse (including microdiscectomy)' -- some of the codes are also used for HVLC Lumbar Decompression / Discectomy

		when --(Treatment_Function_Code in ('110','214') or Main_Specialty_Code = '110') and
		left(Primary_Procedure_Code,4) =  'W371'
				Then 'Primary total prosthetic replacement of the hip' -- this code is also used for HVLC Total hip replacement


------ Emergency Surgery
		--when left(Primary_Procedure_Code,4) in ('Q101','Q102') and
		--	 SK_EncounterID in (select SK_EncounterID from [Data_Lab_NCL].dbo.ip_diag_vw where left(diag,3) = 'O03')
		--		Then 'Evacuation of retained products of conception (spontaneous miscarriage)' -- codes also used for Termination of Pregnancy (medical abortion) under Gynae Specialty



End as [Procedure Sub Category]

,case when Admission_Method_Hospital_Provider_Spell in ('11', '12', '13') and Patient_Classification = '2' Then 'DC'
		when Admission_Method_Hospital_Provider_Spell in ('11', '12', '13') and Patient_Classification = '1' Then 'EL'
		when Admission_Method_Hospital_Provider_Spell in ('11', '12', '13') and Patient_Classification in ('3', '4') Then 'RA' -- Regular Attender (day & night)
		when Admission_Method_Hospital_Provider_Spell in ('21', '22', '23', '24', '25', '28','2A','2B','2C','2D') and datediff(day,Start_Date_Hospital_Provider_Spell,End_Date_Hospital_Provider_Spell) = 0 Then 'NEL-ZLOS'
		when Admission_Method_Hospital_Provider_Spell in ('21', '22', '23', '24', '25', '28','2A','2B','2C','2D') and datediff(day,Start_Date_Hospital_Provider_Spell,End_Date_Hospital_Provider_Spell) >=1 Then 'NEL-LOS+1'
		when Admission_Method_Hospital_Provider_Spell in ('31', '32','82', '83') Then 'NELNE'
		when Admission_Method_Hospital_Provider_Spell = '81' Then 'TRANSFERS'
			Else 'OTHER' 
				End as [POD]
,case when Admission_Method_Hospital_Provider_Spell in ('11', '12', '13') and Patient_Classification = '1' Then 1 End as [Elective]
,case when Admission_Method_Hospital_Provider_Spell in ('11', '12', '13') and Patient_Classification = '2'  Then 1 End as [Daycase]
,case when Admission_Method_Hospital_Provider_Spell in ('11', '12', '13') and Patient_Classification in ('1','2') Then 1 End as [Total Elective]
,case when Admission_Method_Hospital_Provider_Spell in ('11', '12', '13') and Patient_Classification = '2' and [Intended_Management] = 2 Then 'Patients booked as daycases and done as daycases'
		when Admission_Method_Hospital_Provider_Spell in ('11', '12', '13') and Patient_Classification = '1' and [Intended_Management] = 2 Then 'Patients booked as daycases but stayed in overnight'
		when [Intended_Management] = 1 Then 'Patients booked as inpatients/overnight stays'
			Else 'Other'
				End as [Booked vs Admission Type]
,case when SK_EncounterID in (select SK_EncounterID from [Data_Lab_NCL].[dbo].[ip_opcs_vw] where left([opcs],3) between 'X70' and 'X74') Then 'Chemo'
		when SK_EncounterID in (select SK_EncounterID from [Data_Lab_NCL].[dbo].[ip_opcs_vw] where left([opcs],3) between 'X65' and 'X67' or
			left([opcs],3) between 'Y91' and 'Y92' or
			left([opcs],4) = 'X657' or
			left([opcs],4) between 'Y915' and 'Y917' or
			LEFT([opcs],3) in ('O44','X69')) Then 'Radiotherapy'
				End as [Excluded Flag]
,case when left(Organisation_Code_Code_of_Commissioner,3) in ('07M','07R','07X','08D','08H','93C') Then 'NCL' Else 'Non-NCL' End as [NCL\Non-NCL]
,1 as activity

from [SUS].[IP].[EncounterDenormalised_DateRange] ip

left outer join Dictionary.[dbo].[HRG] hrg
on ip.[Spell_Core_HRG] = hrg.[HRGCode]

left outer join Dictionary.[dbo].[Procedure] opcs
on left(ip.Primary_Procedure_Code,4) = opcs.[Code]

left outer join Dictionary.[dbo].[Specialties] tfc
on ip.Treatment_Function_Code = tfc.[BK_SpecialtyCode]

left outer join Dictionary.[dbo].[Specialties] spec
on ip.Main_Specialty_Code = spec.[BK_SpecialtyCode]

left outer join dictionary.dbo.Organisation org 
on org.Organisation_Code = ip.[Organisation_Code_Code_of_Provider]

where dv_IsSpell = 1
and (left(Organisation_Code_Code_of_Provider,3) in ('RAP','RKE','RAN','RRV','RAL','RP6','RP4') or Organisation_Code_Code_of_Provider in ('NT451','NT421','NT416','NYW03','G3Q3Z')) -- 5/2023 Added IS providers as per Andrew Wilsher-Gawthorpe request
--and dv_FinYear in ('2018/2019','2019/2020','2020/2021','2021/2022','2022/2023')
and dv_FinYear in ('2022/2023','2023/2024')
and Admission_Method_Hospital_Provider_Spell in ('11', '12', '13')
and Patient_Classification in ('1','2') 

) ip

left outer join [Data_Lab_NCL].[dbo].[daycase_metrics] dc
on ip.[Procedures] = dc.[Metric]

--where [Procedures] <> 'Other'

group by
FinYear
,[Month]
,[Adult/Paed]
,Treatment_Function_Code
--,[TFC Desc] 
,Main_Specialty_Code
,[Main Specialty]
,[Provider Code]
,[Provider Name]
,[HRG Code]
,[HRG Desc]
,[Procedure Code]
,[Procedure Desc]
,POD
,[Procedures]
,[Booked vs Admission Type]
,[Grouped LoS]
,Qtr
,[Procedure Sub Category]
,[Age Group]
,[Critical care Flag]
,[Excluded Flag]
,[NCL\Non-NCL]
,Specialty

GO

update #DCRate
set [Procedures] = 'HVLC Vaginal hysterectomy and/or vaginal wall repair'
,Benchmark = .204
where [Procedures] = 'HVLC Laparoscopic hysterectomy' and [Procedure Sub Category] = 'Vaginal hysterectomy'
GO

--If(OBJECT_ID(N'[dbo].[daycase_rates]',N'U') Is Not Null) 
--Begin
--    Drop Table [dbo].[daycase_rates]
--End

delete [dbo].[daycase_rates] where FinYear in ('2022/23','2023/24')
GO

insert into [dbo].[daycase_rates]
select * --into [dbo].[daycase_rates]
from
(
select 
concat(finyear, ' (' , Month, ')') as [Period]
,FinYear
,[Month]
,Qtr
,[Adult/Paed]
,[Provider Name]
,[Provider]
,POD
,[Grouped Specialty]
--,[Treatment Function]
--,[Main Specialty]
,[Procedures]
,[Procedure Sub Category]
,[HVLC Flag]
,Benchmark
,[Booked vs Admission Type]
,[Grouped LoS]
,[Age Group]
,[Critical care Flag]
,[Excluded Flag]
,[NCL\Non-NCL]
,sum(Elective) as Elective
,sum(Daycase) as Daycase
,0 as OP
,sum(Activity) as Activity

from #DCRate

group by
FinYear
,[Month]
,Qtr
,[Adult/Paed]
,[Provider Name]
,[Provider]
,POD
,[Grouped Specialty]
--,[Treatment Function]
--,[Main Specialty]
,[Procedures]
,[Procedure Sub Category]
,[HVLC Flag]
,Benchmark
,[Booked vs Admission Type]
,[Grouped LoS]
,[Age Group]
,[Critical care Flag]
,[Excluded Flag]
,[NCL\Non-NCL]

UNION ALL

select distinct
concat(finyear, ' (' , Month, ')') as [Period]
,FinYear
,[Month]
,Qtr
,[Adult/Paed]
,'Benchmark'
,'Benchmark'
,POD
,[Grouped Specialty]
--,[Treatment Function]
--,[Main Specialty]
,[Procedures]
,[Procedure Sub Category]
,[HVLC Flag]
,Benchmark
,[Booked vs Admission Type]
,[Grouped LoS]
,[Age Group]
,[Critical care Flag]
,[Excluded Flag]
,[NCL\Non-NCL]
,1-Benchmark
,Benchmark
,Benchmark
,Benchmark
from #DCRate

UNION ALL

select 
concat(finyear, ' (' , Month, ')') as [Period]
,FinYear
,[Month]
,Qtr
,[Adult/Paed]
,'NCL'
,'NCL'
,POD
,[Grouped Specialty]
--,[Treatment Function]
--,[Main Specialty]
,[Procedures]
,[Procedure Sub Category]
,[HVLC Flag]
,Benchmark
,[Booked vs Admission Type]
,[Grouped LoS]
,[Age Group]
,[Critical care Flag]
,[Excluded Flag]
,[NCL\Non-NCL]
,sum(Elective) as Elective
,sum(Daycase) as Daycase
,0 as OP
,sum(Activity) as Activity

from #DCRate
where Provider in ('North Middlesex','UCLH','Whittington','Royal Free','RNOH','Moorfields','GOSH')

group by
FinYear
,[Month]
,[Adult/Paed]
,POD
,[Grouped Specialty]
--,[Treatment Function]
--,[Main Specialty]
,[Procedures]
,[Procedure Sub Category]
,[HVLC Flag]
,[Booked vs Admission Type]
,[Grouped LoS]
,[Age Group]
,[Critical care Flag]
,[Excluded Flag]
,[NCL\Non-NCL]
,Qtr
,Benchmark

UNION ALL

select 
concat(finyear, ' (' , Month, ')') as [Period]
,FinYear
,[Month]
,Qtr
,[Adult/Paed]
,[Provider Name]
,[Provider]
,POD
,[Grouped Specialty]
--,NULL as [Treatment Function]
--,NULL as [Main Specialty]
,[Procedures]
,[Procedure Sub Category]
,[HVLC Flag]
,Benchmark
,[Booked vs Admission Type]
,[Grouped LoS]
,[Age Group]
,[Critical care Flag]
,NULL as [Excluded Flag]
,NULL as [NCL\Non-NCL]
,Elective
,Daycase
,OP
,Activity
from [dbo].[HVLC_OPPROC]

UNION ALL

select distinct
concat(finyear, ' (' , Month, ')') as [Period]
,FinYear
,[Month]
,Qtr
,[Adult/Paed]
,'85% Target'
,'85% Target'
,POD
,[Grouped Specialty]
--,[Treatment Function]
--,[Main Specialty]
,[Procedures]
,[Procedure Sub Category]
,[HVLC Flag]
,Benchmark
,[Booked vs Admission Type]
,[Grouped LoS]
,[Age Group]
,[Critical care Flag]
,[Excluded Flag]
,[NCL\Non-NCL]
,1-.85
,.85
,.85
,.85
from #DCRate

UNION ALL

select 
concat(finyear, ' (' , Month, ')') as [Period]
,FinYear
,[Month]
,Qtr
,[Adult/Paed]
,'19/20 Average'
,'19/20 Average'
,POD
,[Grouped Specialty]
--,[Treatment Function]
--,[Main Specialty]
,[Procedures]
,[Procedure Sub Category]
,[HVLC Flag]
,Benchmark
,[Booked vs Admission Type]
,[Grouped LoS]
,[Age Group]
,[Critical care Flag]
,[Excluded Flag]
,[NCL\Non-NCL]
,sum(Elective) as Elective
,sum(Daycase) as Daycase
,0 as OP
,sum(Activity) as Activity

from #DCRate

group by
FinYear
,[Month]
,[Adult/Paed]
,POD
,[Grouped Specialty]
--,[Treatment Function]
--,[Main Specialty]
,[Procedures]
,[Procedure Sub Category]
,[HVLC Flag]
,[Booked vs Admission Type]
,[Grouped LoS]
,[Age Group]
,[Critical care Flag]
,[Excluded Flag]
,[NCL\Non-NCL]
,Qtr
,Benchmark
) DCR


