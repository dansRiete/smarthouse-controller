CREATE TABLE hour_change_tracker (
                                     id SERIAL PRIMARY KEY,
                                     previous_hour INT,
                                     updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO hour_change_tracker (id, previous_hour, updated_at) VALUES (1, -1, now());
