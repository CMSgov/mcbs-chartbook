# Medicare Current Beneficiary Survey (MCBS)
The Medicare Current Beneficiary Survey (MCBS) is a continuous, multipurpose survey of a nationally representative sample of the Medicare population, conducted by the Office of Enterprise Data and Analytics (OEDA) of the Centers for Medicare & Medicaid Services (CMS) through a contract with NORC at the University of Chicago. The central goals of the MCBS are to determine expenditures and sources of payment for all services used by Medicare beneficiaries, including co-payments, deductibles, and non-covered services; to ascertain all types of health insurance coverage and relate coverage to sources of payment; and to trace outcomes over time, such as changes in health status and spending down to Medicaid eligibility and the impacts of Medicare program changes on satisfaction with care and usual source of care. The MCBS provides important information on health outcomes and social determinants of health not available in the administrative program data.

MCBS data are made available via releases of annual files. For each data year, two annual LDS releases (the Survey File and the Cost Supplement File) and two PUFs (based on the Survey File and Cost Supplement File, respectively) are planned. The Survey File contains information on beneficiaries’ demographic information, health insurance coverage, self-reported health status and conditions, and responses regarding access to care and satisfaction with care. The Cost Supplement File contains a comprehensive accounting of beneficiaries’ health care use, expenditures, and sources of payment.  

The LDS releases contain multiple files, called segments, which are easily linkable through a common beneficiary key ID. Detailed descriptions of each segment can be found below.

## Survey File 
### Access to Care (ACCESSCR)
The Access to Care segment contains information from the HFQ section in the fall round. General questions are asked about the beneficiary’s ability to access medical services. This segment also contains information on medical debt and the reasons beneficiaries cannot access the care they need.
### Access to Care, Medical Appointments (ACCSSMED)
The Access to Care, Medical Appointments segment contains information from the ACQ section and the emergency room, outpatient, medical provider, dental, vision, and hearing, and prescription medicine utilization sections asked in the winter round following the year of interest. General questions are asked about the beneficiary’s access to all types of medical services and prescription medicines, the reasons for their visits, and the reasons for any forgone care or prescription medicines. 
### Administrative Utilization Summary (ADMNUTLS)
The Administrative Utilization Summary segment contains information on Medicare program expenditures and utilization taken directly from the Medicare Administrative enrollment data. 
### Assistance (ASSIST)
The Assist segment contains information on each person identified as helping the beneficiary with ADLs or IADLs, including the helper’s age, relationship to the beneficiary, and the types of assistance that the beneficiary receives (e.g., assistance with dressing, shopping, eating) from each identified helper. The number of records in the Assist segment reflects the number of persons identified as having assisted the beneficiary with one or more ADL or IADLs. Therefore, it is possible to have one, several, or no helper records per beneficiary. 
### Chronic Conditions (CHRNCOND) 
The Chronic Conditions segment contains information on whether the beneficiary has a series of chronic and other diagnosed medical conditions such as cancer, high blood pressure, and depression. If the respondent reports that the beneficiary has the condition, a series of follow-up questions is asked.
### Chronic Condition Flags (CHRNCDFL)
The Chronic Conditions Flags segment contains chronic and other disabling conditions flags from administrative FFS records from the CCW. The CCW summarizes beneficiaries’ FFS claims for the calendar year and indicates whether a claim for a particular condition met criteria for inclusion. This segment also provides the first year the beneficiary met the criteria for having that chronic condition. Variables are included for those conditions related to the self-reported information included in the MCBS instrument and are not inclusive of all chronic and disabling conditions available.
### Chronic Pain (CHRNPAIN)
The Chronic Pain segment contains data on beneficiaries’ experiences with chronic pain and chronic pain management techniques collected in the CPQ section administered the summer following the year of interest. The CPQ collects information related to frequency and severity of chronic pain, location of chronic pain (e.g., hips, knees, or feet), and use of pain management techniques (e.g., massage). 
### Cognitive Measures (COGNFUNC)
The Cognitive Measures segment contains data on the beneficiary’s cognitive abilities collected in the CMQ section administered in the fall rounds. The CMQ contains four cognitive measures, including backwards counting, date naming, object naming, and president/vice president naming.
### Community COVID-19 Vaccine Dosage (COMMDOSE)
The Community COVID-19 Vaccine Dosage segment contains information collected in the CVQ section about COVID-19 vaccine dose(s) beneficiaries received including dose month and year, manufacturer, and where they received the dose(s) (e.g., pharmacy, hospital, etc.), collected during the Winter 2022 and Summer 2022 rounds.
### COVID-19 Experiences (COVIDEXP)
The COVID-19 Experiences segment contains information collected in the CVQ section during the fall round, and it includes data on COVID-19 vaccination, testing, diagnosis, symptoms, and prevention.
### Demographics (DEMO)
The Demographics segment contains demographic information collected in the survey as well as demographic information from Medicare Administrative enrollment data and constructed items of interest. 
### Diabetes (DIABETES)
The Diabetes segment includes survey responses related to diabetes management. Only beneficiaries living in the community who indicated that they had ever been told they have non-gestational diabetes (variable D_OCDTYP in the Chronic Condition segment) are included in the Diabetes segment. This segment includes beneficiaries who indicated they had been diagnosed with any of these diabetic conditions: Type 1, Type 2, pre-diabetes/borderline diabetes, or other non-gestational type of diabetes.
### Facility Assessments (FACASMNT)
CMS designed the MDS instrument to collect information regarding the health status and functioning of nursing home residents. The MDS is administered to anyone residing in a certified nursing home, regardless of payer. About half of MCBS beneficiaries living in a facility at the time of their interview live in certified nursing homes. For this reason, the MCBS Facility instrument has been designed to mirror the MDS instrument. 
### Facility Characteristics (FACCHAR)
The Facility Characteristics segment is constructed using data from the Facility Questionnaire, which provides information about survey-collected facility stays, and the administrative Provider of Service (POS) file, which provides facility characteristics pertaining to SNF stays.

For a beneficiary in the current year’s population file, any facility stay within a round from the current file year, as well as from the following winter round, provided that it has an admission date that falls within the current file year, is included in the file. The inclusion of these winter round records is meant to capture any stays which began after the conclusion of the fall round for a given file year. Selected data from the POS file is also included for any SNF stay occurring during the file year for beneficiaries on the finder file.
### Falls (FALLS)
The Falls segment contains responses related to injuries and attitudes related to falls. 
### Food Insecurity (FOODINS)
The Food Insecurity segment contains information regarding the beneficiary’s access to sufficient food. These questions are part of the IAQ and are based upon the USDA ERS Six-Item Short Form of the Food Security Survey Module found at https://www.ers.usda.gov/topics/food-nutrition-assistance/food-security-in-the-us/survey-tools. 
### General Health (GENHLTH)
The General Health segment contains data regarding a beneficiary’s general health status and functioning such as height and weight. 
### Health Insurance Summary (HISUMRY)
The Health Insurance Summary segment contains information on administrative plans and their characteristics. Specifically, it includes flags for monthly enrollment and dual eligibility status and information on premiums, co-pays, deductibles, and capitated payments. The file also includes EST_TPRM, which is the sum of premiums for Parts A, B, C, and D and premiums for other plans (private coverage purchased directly from an insurance company, etc.).
### Health Insurance Timeline (HITLINE)
The Health Insurance Timeline segment contains one record for each plan a beneficiary has and includes information on type of insurance coverage, monthly eligibility/enrollment, coverage start and end dates, and the source information for the coverage. For all plans that a beneficiary has, both administrative and survey reported are included on the file. However, starting with 2021, survey reports of Medicare Advantage (MA) enrollment with no corresponding record of MA enrollment in administrative data have been excluded. In addition, HITLINE contains detailed information on plans for which no administrative data are available. These plans are reported in the survey only and include different types of private plans, Tricare, coverage for certain medical events through the Department of Veteran’s Affairs for beneficiaries living in a facility, and public plans that do not fall under either Medicare or Medicaid. For these survey-only plans, the file includes flags indicating types of services covered, and, for private plans, information on plan policyholder and premiums paid. All plans reported in a Community setting also have a unique plan identifier, PLANNUM, which can be used to link plans across multiple years. 
The questionnaire does not ask whether a given plan offers ‘comprehensive’ coverage. Data users can construct their own definition of comprehensive coverage and consult individual coverage flags to determine if a plan meets their criterial for being a comprehensive plan.
### Household Characteristics (HHCHAR) 
The Household Characteristics segment includes beneficiaries who resided in a community setting as of their last complete interview and contains information about the beneficiary’s household composition and residence. For each calendar year, this segment reflects the latest available data on the size of the household and the age and relationship of household members. Information about the beneficiary’s physical residence is collected at the Baseline interview and updated as necessary.  
### Income and Assets (INCASSET) 
This segment contains data on a beneficiary’s reported income and assets. 
### Interview Characteristics (INTERV)
The Interview Characteristics segment summarizes interview characteristics, such as the type of interview and whether a proxy is used. 
### Medicare Advantage Plan Questions (MAPLANQX)
The MA Plan Questions segment augments information from the ACQ and SCQ sections of the questionnaire for those beneficiaries enrolled in Medicare Part C. Beneficiaries who are enrolled in an MA plan at the time of the interview are asked general questions about their health plans, which include access to and satisfaction with medical services. This segment also contains the beneficiary’s assessment of the quality of the medical care that they are receiving, types of additional coverage offered, and any beneficiary-paid premiums associated with the health plan. 
### Medicare Plan Beneficiary Knowledge (MCREPLNQ)
The Medicare Plan Beneficiary Knowledge segment contains information from the KNQ section related to the beneficiary’s knowledge about the Medicare open enrollment period and Medicare-covered expenses. The KNQ is administered the winter following the year of interest. 
The data collected in this segment support evaluation of the impact of existing education initiatives by CMS. The KNQ section helps refine future CMS education initiatives by asking about information that beneficiaries may need, preferred sources for this information, and beneficiaries’ access to insurance information. This data also presents the knowledge beneficiaries have gained from CMS publications.
### Minimum Data Set (MDS3)
The Minimum Data Set is health assessment information collected while the beneficiary was in an approved Medicare Facility. For more information regarding the MDS and the changes in version 3.0, please consult https://www.cms.gov/Medicare/Quality-Initiatives-Patient-Assessment-Instruments/NursingHomeQualityInits/index. 
### Mental Health (MENTHLTH)
The Mental Health segment contains survey responses regarding the beneficiary’s mental health such as feelings of anxiety or depression.
### Mobility (MOBILITY)
The Mobility segment contains information on the beneficiary’s use of available transportation options and whether the beneficiary’s health affects their daily travel.
### Multiple Year Enrollment (MYENROLL)
The Multiple Year Enrollment segment combines five years of enrollment information for the current year MCBS beneficiary population. This allows users to view multiple years of enrollment information in one file.
### Nagi Disability (NAGIDIS)
The Nagi Disability segment contains information on the beneficiary’s difficulties with performing ADLs and IADLs, including which ADLs and IADLs the beneficiary has difficulty performing, how long the beneficiary has experienced these difficulties, whether the beneficiary has received any help or used supportive equipment to perform ADLs or IADLs, and the total number of persons who have helped the beneficiary, if applicable. 
### Nicotine and Alcohol (NICOALCO)
The Nicotine and Alcohol segment contains information on the prevalence and frequency of alcohol and nicotine use (including cigarettes, e-cigarettes, cigars, pipe tobacco, and smokeless tobacco). 
### Outcome and Assessment Information (OASIS)
The Outcome and Assessment Information segment contains assessment information conducted while the beneficiary was receiving home health services. 

For more information regarding OASIS, please consult https://www.cms.gov/Medicare/Quality-Initiatives-Patient-Assessment-Instruments/HomeHealthQualityInits. 
### Patient Activation (PNTACT) 
The Patient Activation segment contains data that can be used to assess the degree to which beneficiaries actively participate in their own health care and the decisions concerning their health care, measuring if beneficiaries receive information about their health and Medicare and if they understand the information in a way that makes it useful. 
### Preventive Care (PREVCARE)
The Preventive Care segment provides data on the beneficiary’s use of preventive services, including getting a mammogram, Pap smear, prostate screening, diabetes screening, colon cancer screening, blood pressure screening, flu and pneumonia shots, shingles vaccine, and HIV testing.
### Residence Timeline (RESTMLN)
The Residence Timeline segment provides a timeline of each MCBS setting type in which a beneficiary resides over the portion of the year in which they are enrolled in Medicare, as well as any periods associated with FFS inpatient, SNF, or hospice events. 
### RX Medications (RXMED)
The RX Medications segment augments information from the ACQ and SCQ sections of the questionnaire with information specific to prescription drug coverage collected in the RXQ section. The RXQ covers topics related to knowledge about and experience with Medicare Part D enrollment, options considered when choosing prescription drug coverage, access to prescription drugs, and satisfaction with current prescription drug coverage.
### Satisfaction with Care (SATWCARE)
The Satisfaction with Care segment contains data from the SCQ section on satisfaction with different aspects of medical care, such as cost and the information provided by the beneficiary’s medical care provider. The questions about satisfaction with care represent the respondent’s general opinion of all medical care received in the year preceding the interview.
### Telemedicine (TELEMED)
The Telemedicine segment contains data from TLQ about the availability of telemedicine visits and the beneficiary’s use of telemedicine visits.
### Usual Source of Care (USCARE)
The Usual Source of Care segment contains data from USQ on where and how the beneficiary typically seeks medical care. 
### Vision and Hearing (VISHEAR)
The Vision and Hearing segment contains information on the beneficiary’s eye health and hearing status. 
### COVID-19 Facility Beneficiary-Level Supplement (FBENCVFL)
The COVID-19 Facility Beneficiary-Level Supplement segment contains information collected in the CV section in Fall 2021 and Winter 2022, including COVID-19 vaccination, diagnosis, testing, and care received by different types of health care providers. 
### COVID-19 Facility Facility-Level Supplement (FFACCVFL)
The COVID-19 Facility Facility-Level Supplement segment contains COVID-19 related information collected in the FC section in Fall 2021 and Winter 2022, including telehealth services provided, suspension of in-person services, prevention activities, prospective vaccination policies for staff and residents, personnel changes, mental health services provided, and social/recreational services provided.





















## Cost Supplement File 




# Data Access
All requested LDS files require a signed LDS Data Use Agreement (DUA) between CMS and the data requestor to ensure that the data remain protected against unauthorized disclosure. LDS requestors must show that their proposed use of the data meets the disclosure provisions for research. The research purpose must relate to projects that could ultimately improve the care provided to Medicare patients and policies that govern the care. This type of research includes projects related to improving the quality of life for Medicare beneficiaries, improving the administration of the Medicare program, cost and payment related projects, and the creation of analytical reports. In addition, these research projects must contribute to generalizable knowledge.

Data users can submit an LDS request via a CMS DUA tracking system, the Enterprise Privacy Policy Engine or EPPE. EPPE can be used to initiate a new LDS DUA request or to amend/update an existing LDS DUA. Questions about LDS files or the process for requesting LDS files can be sent to datauseagreement@cms.hhs.gov. For additional information on data access and the DUA process, including instructions for accessing and using EPPE to make a request, data users can visit the CMS LDS website at https://www.cms.gov/Research-Statistics-Data-and-Systems/Files-for-Order/Data-Disclosures-Data-Agreements/DUA_-_NewLDS. 

The processing of the DUA takes approximately six to eight weeks. Upon approval and payment, CMS releases the data within ten business days, depending on the size of the data request. Data users will receive the data on DVD or via the CMS Virtual Research Data Center (VRDC) for use with SAS® or other statistical software packages; each data release contains multiple files that are linkable through a key identification variable (BASEID). 

Questionnaires, codebooks, and Bibliographies for each survey year are available for download on the CMS MCBS website at https://www.cms.gov/Research-Statistics-Data-and-Systems/Research/MCBS. A link to this documentation is also visible when approved data users log in to the VRDC. 



