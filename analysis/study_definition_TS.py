from cohortextractor import StudyDefinition, patients, Measure, codelist, codelist_from_csv, combine_codelists  # NOQA

# CODE LISTS
# All codelists are held within the codelist/ folder

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

# STUDY POPULATION
index_date = "2019-01-01"
end_date = "today"

study = StudyDefinition(
    default_expectations={
        "date": {"earliest": index_date, "latest": "today"},
        "rate": "uniform",
        "incidence": 1,
    },
    index_date=index_date,
    population=patients.registered_with_one_practice_between(
        index_date, end_date
    ),
    age=patients.age_as_of(
        index_date,
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
    imdQ5=patients.categorised_as(
        {
            "Unknown": "DEFAULT",
            "1 (most deprived)": "imd >= 0 AND imd < 32844*1/5",
            "2": "imd >= 32844*1/5 AND imd < 32844*2/5",
            "3": "imd >= 32844*2/5 AND imd < 32844*3/5",
            "4": "imd >= 32844*3/5 AND imd < 32844*4/5",
            "5 (least deprived)": "imd >= 32844*4/5 AND imd <= 32844",
        },
        imd=patients.address_as_of(
            index_date,
            returning="index_of_multiple_deprivation",
            round_to_nearest=100,
        ),
        return_expectations={
            "category": {"ratios": {
                "1 (most deprived)": 0.2,
                "2": 0.2,
                "3": 0.2,
                "4": 0.2,
                "5 (least deprived)": 0.2}},
            "incidence": 1,
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
        index_date,
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
    Diabetes=patients.with_these_clinical_events(
        diabetes_t2_codes,
        on_or_before=index_date,
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.6},
    ),
    VTE_AF=patients.with_these_clinical_events(
        VTE_AF_codes,
        on_or_before=index_date,
        returning="binary_flag",
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.6},
    ),
    DOACs=patients.with_these_medications(
        DOAC_codes,
        returning="binary_flag",
        between=[index_date, end_date],
        find_first_match_in_period=True,
        return_expectations={"incidence": 0.2},
    ),
    Warfarin=patients.with_these_medications(
        Warfarin_codes,
        returning="binary_flag",
        find_first_match_in_period=True,
        between=[index_date, end_date],
        return_expectations={"incidence": 0.2},
    ),
    SGLT2s=patients.with_these_medications(
        SGLT2_codes,
        returning="binary_flag",
        find_first_match_in_period=True,
        between=[index_date, end_date],
        return_expectations={"incidence": 0.2},
    ),
    Diabetes_SOCs=patients.with_these_medications(
        Diabetes_SOC_codes,
        returning="binary_flag",
        find_first_match_in_period=True,
        between=[index_date, end_date],
        return_expectations={"incidence": 0.2},
    ),
)

measures = [
    Measure(
        id="SGLT2_ethnicity",
        numerator="SGLT2s",
        denominator="Diabetes",
        group_by="ethnicity"
    ),
    Measure(
        id="SGLT2_region",
        numerator="SGLT2s",
        denominator="Diabetes",
        group_by="region"
    ),
]
