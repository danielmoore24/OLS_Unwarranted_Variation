from cohortextractor import StudyDefinition, patients, codelist, codelist_from_csv, combine_codelists, Measure  # NOQA

# Defining codelists
ethnicity_codes = codelist_from_csv(
    "codelists/opensafely-ethnicity.csv",
    system="ctv3",
    column="Code",
    category_column="Grouping_6",
)

diabetes_t2_codes = codelist_from_csv(
    "codelists/opensafely-type-2-diabetes.csv",
    system="ctv3",
    column="CTV3ID"
)

VTE_codes = codelist_from_csv(
    "codelists/opensafely-vte-classified-codes.csv",
    system="ctv3",
    column="CTV3Code"
)

AF_codes = codelist_from_csv(
    "codelists/opensafely-atrial-fibrillation-clinical-finding.csv",
    system="ctv3",
    column="CTV3Code"
)

VTE_AF_codes = combine_codelists(
    VTE_codes,
    AF_codes
)

DOAC_codes = codelist_from_csv(
    "codelists/opensafely-direct-acting-oral-anticoagulants-doac.csv",
    system="snomed",
    column="id"
)

Warfarin_codes = codelist_from_csv(
    "codelists/opensafely-warfarin.csv",
    system="snomed",
    column="id"
)

SGLT2_codes = codelist_from_csv(
    "codelists/user-danielmoore24-sglt2-inhibitors.csv",
    system="snomed",
    column="code"
)

Diabetes_SOC_codes = codelist_from_csv(
    "codelists/user-danielmoore24-diabetes-standard-of-care.csv",
    system="snomed",
    column="code"
)


# Set up study
study = StudyDefinition(
    default_expectations={
        "date": {"earliest": "1900-01-01", "latest": "today"},
        "rate": "uniform",
        "incidence": 0.5,
    },
    population=patients.registered_with_one_practice_between(
        "2019-02-01", "2020-02-01"
    ),
    age=patients.age_as_of(
        "2019-09-01",
        return_expectations={
            "rate": "universal",
            "int": {"distribution": "population_ages"},
        },
    ),
    sex=patients.sex(
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"M": 0.49, "F": 0.51}},
        },
    ),
    imd=patients.address_as_of(
        "2019-09-01",
        returning="index_of_multiple_deprivation",
        round_to_nearest=100,
        return_expectations={
            "rate": "universal",
            "category": {"ratios": {"100": 0.1, "200": 0.2, "300": 0.7}},
        },
    ),
    ethnicity=patients.with_these_clinical_events(
        ethnicity_codes,
        returning="category",
        find_last_match_in_period=True,
        include_date_of_match=True,
        return_expectations={
            "category": {"ratios": {
                "1": 0.2,
                "2": 0.2,
                "3": 0.2,
                "4": 0.2,
                "5": 0.2}},
            "incidence": 0.75,
        },
    ),
    region=patients.registered_practice_as_of(
        "2019-09-01",
        returning="nuts1_region_name",
        return_expectations={
            "rate": "universal",
            "category": {
                "ratios": {
                    "North East": 0.1,
                    "North West": 0.1,
                    "Yorkshire and the Humber": 0.1,
                    "East Midlands": 0.1,
                    "West Midlands": 0.1,
                    "East of England": 0.1,
                    "London": 0.2,
                    "South East": 0.2,
                },
            },
        },
    ),
    type2_diabetes=patients.with_these_clinical_events(
        diabetes_t2_codes,
        on_or_before="2019-09-01",
        return_first_date_in_period=True,
        include_month=True,
    ),
    diabetes=patients.categorised_as(
        {
            "Diabetes": "type2_diabetes",
            "No_Diabetes": "DEFAULT",
        },
        return_expectations={
            "category": {"ratios": {"Diabetes": 0.2, "No_Diabetes": 0.8}},
            "rate": "universal"
        },
    ),
    VTE_AF=patients.with_these_clinical_events(
        VTE_AF_codes,
        on_or_before="2019-09-01",
        return_first_date_in_period=True,
        include_month=True,
    ),
    VTE_or_AF=patients.categorised_as(
        {
            "VTE_or_AF": "VTE_AF",
            "No_VTE_or_AF": "DEFAULT",
        },
        return_expectations={
            "category": {"ratios": {"VTE_or_AF": 0.05, "No_VTE_or_AF": 0.95}},
            "rate": "universal"
        },
    ),
    DOACs=patients.with_these_medications(
        DOAC_codes,
        between=["2019-02-01", "2020-02-01"],
    ),
    DOAC_users=patients.categorised_as(
        {
            "DOAC_user": "DOACs",
            "Not_DOAC_user": "DEFAULT",
        },
        return_expectations={
            "category": {"ratios": {"DOAC_user": 0.02, "Not_DOAC_user": 0.98}},
            "rate": "universal"
        },
    ),
    Warfarin=patients.with_these_medications(
        Warfarin_codes,
        between=["2019-02-01", "2020-02-01"],
    ),
    Warfarin_users=patients.categorised_as(
        {
            "Warfarin_user": "Warfarin",
            "Not_Warfarin_user": "DEFAULT",
        },
        return_expectations={
            "category": {
                "ratios": {
                    "Warfarin_user": 0.07,
                    "Not_Warfarin_user": 0.93}},
            "rate": "universal"
        },
    ),
    SGLT2s=patients.with_these_medications(
        SGLT2_codes,
        between=["2019-02-01", "2020-02-01"],
    ),
    SGLT2_users=patients.categorised_as(
        {
            "SGLT2_user": "SGLT2s",
            "Not_SGLT2_user": "DEFAULT",
        },
        return_expectations={
            "category": {
                "ratios": {
                    "SGLT2_user": 0.04,
                    "Not_SGLT2_user": 0.96}},
            "rate": "universal"
        },
    ),
    Diabetes_SOCs=patients.with_these_medications(
        Diabetes_SOC_codes,
        between=["2019-02-01", "2020-02-01"],
    ),
    Diabetes_SOC_users=patients.categorised_as(
        {
            "Diabetes_SOC_user": "Diabetes_SOCs",
            "Not_Diabetes_SOC_user": "DEFAULT",
        },
        return_expectations={
            "category": {
                "ratios": {
                    "Diabetes_SOC_user": 0.1,
                    "Not_Diabetes_SOC_user": 0.9}},
            "rate": "universal"
        },
    ),
)
#
# Set up measures
# measures = [
#     Measure(
#         id="DOACs_region",
#         numerator="DOAC_user",
#         denominator="VTE_AF",
#         group_by="region",
#     ),
# ]
