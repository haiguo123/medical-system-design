CREATE TABLE IF NOT EXISTS admissions (
    subject_id INTEGER NOT NULL,
    hadm_id INTEGER NOT NULL,
    admittime TIMESTAMP NOT NULL,
    dischtime TIMESTAMP,
    deathtime TIMESTAMP,
    admission_type VARCHAR(40) NOT NULL,
    admit_provider_id VARCHAR(10),
    admission_location VARCHAR(60),
    discharge_location VARCHAR(60),
    insurance VARCHAR(255),
    language VARCHAR(10),
    marital_status VARCHAR(30),
    race VARCHAR(80),
    edregtime TIMESTAMP,
    edouttime TIMESTAMP,
    hospital_expire_flag SMALLINT,
    PRIMARY KEY (hadm_id),
    FOREIGN KEY (subject_id) REFERENCES patients(subject_id)
);

CREATE TABLE IF NOT EXISTS chartevents (
    subject_id INTEGER,
    hadm_id INTEGER,
    stay_id INTEGER,
    caregiver_id INTEGER,
    charttime TIMESTAMP(0),
    storetime TIMESTAMP(0),
    itemid INTEGER,
    value VARCHAR(200),
    valuenum DOUBLE PRECISION,
    valueuom VARCHAR(20),
    warning SMALLINT,
    FOREIGN KEY (subject_id) REFERENCES patients(subject_id),
    FOREIGN KEY (hadm_id) REFERENCES admissions(hadm_id),
    FOREIGN KEY (stay_id) REFERENCES icustays(stay_id),
    FOREIGN KEY (itemid) REFERENCES d_items(itemid)
);

CREATE TABLE IF NOT EXISTS d_items (
    itemid INTEGER,
    label VARCHAR(200),
    abbreviation VARCHAR(100),
    linksto VARCHAR(50),
    category VARCHAR(100),
    unitname VARCHAR(100),
    param_type VARCHAR(30),
    lownormalvalue FLOAT,
    highnormalvalue FLOAT,
    PRIMARY KEY (itemid)
);

CREATE TABLE IF NOT EXISTS d_labitems (
    itemid INTEGER,
    label VARCHAR(50),
    fluid VARCHAR(50),
    category VARCHAR(50),
    PRIMARY KEY (itemid)
);

CREATE TABLE IF NOT EXISTS emar (
    subject_id INTEGER NOT NULL,
    hadm_id INTEGER,
    emar_id VARCHAR(25) NOT NULL,
    emar_seq INTEGER NOT NULL,
    poe_id VARCHAR(25),
    pharmacy_id INTEGER,
    enter_provider_id VARCHAR(10),
    charttime TIMESTAMP NOT NULL,
    medication TEXT,
    event_txt VARCHAR(100),
    scheduletime TIMESTAMP,
    storetime TIMESTAMP NOT NULL,
    PRIMARY KEY (emar_id)
);

CREATE TABLE IF NOT EXISTS emar_detail (
    subject_id INTEGER NOT NULL,
    emar_id VARCHAR(25) NOT NULL,
    emar_seq INTEGER NOT NULL,
    parent_field_ordinal VARCHAR(10),
    administration_type VARCHAR(50),
    pharmacy_id INTEGER,
    barcode_type VARCHAR(4),
    reason_for_no_barcode TEXT,
    complete_dose_not_given VARCHAR(5),
    dose_due VARCHAR(100),
    dose_due_unit VARCHAR(50),
    dose_given VARCHAR(255),
    dose_given_unit VARCHAR(50),
    will_remainder_of_dose_be_given VARCHAR(5),
    product_amount_given VARCHAR(30),
    product_unit VARCHAR(30),
    product_code VARCHAR(30),
    product_description VARCHAR(255),
    product_description_other VARCHAR(255),
    prior_infusion_rate VARCHAR(40),
    infusion_rate VARCHAR(40),
    infusion_rate_adjustment VARCHAR(50),
    infusion_rate_adjustment_amount VARCHAR(30),
    infusion_rate_unit VARCHAR(30),
    route VARCHAR(10),
    infusion_complete VARCHAR(1),
    completion_interval VARCHAR(50),
    new_iv_bag_hung VARCHAR(1),
    continued_infusion_in_other_location VARCHAR(1),
    restart_interval TEXT,
    side VARCHAR(10),
    site VARCHAR(255),
    non_formulary_visual_verification VARCHAR(1),
    FOREIGN KEY (emar_id) REFERENCES emar(emar_id)
);

CREATE TABLE IF NOT EXISTS icustays (
    subject_id INT,
    hadm_id INT,
    stay_id INT,
    first_careunit VARCHAR(20),
    last_careunit VARCHAR(20),
    intime TIMESTAMP(0),
    outtime TIMESTAMP(0),
    los DOUBLE PRECISION,
    PRIMARY KEY (stay_id),
    FOREIGN KEY (subject_id) REFERENCES patients(subject_id),
    FOREIGN KEY (hadm_id) REFERENCES admissions(hadm_id)
);

CREATE TABLE IF NOT EXISTS labevents (
    labevent_id INTEGER NOT NULL,
    subject_id INTEGER NOT NULL,
    hadm_id INTEGER,
    specimen_id INTEGER NOT NULL,
    itemid INTEGER NOT NULL,
    order_provider_id VARCHAR(10),
    charttime TIMESTAMP(0),
    storetime TIMESTAMP(0),
    value VARCHAR(200),
    valuenum DOUBLE PRECISION,
    valueuom VARCHAR(20),
    ref_range_lower DOUBLE PRECISION,
    ref_range_upper DOUBLE PRECISION,
    flag VARCHAR(10),
    priority VARCHAR(7),
    comments TEXT,
    PRIMARY KEY (labevent_id),
    FOREIGN KEY (itemid) REFERENCES d_labitems(itemid)
);

CREATE TABLE IF NOT EXISTS patients (
    subject_id INTEGER NOT NULL,
    gender VARCHAR(1) NOT NULL,
    anchor_age INTEGER NOT NULL,
    anchor_year INTEGER NOT NULL,
    anchor_year_group VARCHAR(255) NOT NULL,
    dod TIMESTAMP(0),
    PRIMARY KEY (subject_id)
);

CREATE TABLE IF NOT EXISTS prescriptions (
    subject_id INTEGER NOT NULL,
    hadm_id INTEGER NOT NULL,
    pharmacy_id INTEGER NOT NULL,
    poe_id VARCHAR(25),
    poe_seq INTEGER,
    order_provider_id VARCHAR(10),
    starttime TIMESTAMP(3),
    stoptime TIMESTAMP(3),
    drug_type VARCHAR(20) NOT NULL,
    drug VARCHAR(255) NOT NULL,
    formulary_drug_cd VARCHAR(50),
    gsn VARCHAR(255),
    ndc VARCHAR(25),
    prod_strength VARCHAR(255),
    form_rx VARCHAR(25),
    dose_val_rx VARCHAR(100),
    dose_unit_rx VARCHAR(50),
    form_val_disp VARCHAR(50),
    form_unit_disp VARCHAR(50),
    doses_per_24_hrs REAL,
    route VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS services (
    subject_id INT,
    hadm_id INT,
    transfertime TIMESTAMP(0),
    prev_service VARCHAR(20),
    curr_service VARCHAR(20),
    FOREIGN KEY (subject_id) REFERENCES patients(subject_id),
    FOREIGN KEY (hadm_id) REFERENCES admissions(hadm_id)
);

CREATE TABLE IF NOT EXISTS transfers (
    subject_id INTEGER NOT NULL,
    hadm_id INTEGER,
    transfer_id INTEGER NOT NULL,
    eventtype VARCHAR(10),
    careunit VARCHAR(255),
    intime TIMESTAMP(0),
    outtime TIMESTAMP(0),
    PRIMARY KEY (transfer_id),
    FOREIGN KEY (subject_id) REFERENCES patients(subject_id),
    FOREIGN KEY (hadm_id) REFERENCES admissions(hadm_id)
);
