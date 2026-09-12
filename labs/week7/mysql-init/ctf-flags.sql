USE exampledb;

CREATE TABLE IF NOT EXISTS ctf_flags (
    id INT AUTO_INCREMENT PRIMARY KEY,
    level VARCHAR(10) NOT NULL,
    flag VARCHAR(100) NOT NULL
);

INSERT INTO ctf_flags (level, flag) VALUES
('user', 'flag{w7_sql_enumeration_success}');

CREATE TABLE IF NOT EXISTS helpdesk_tickets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    ticket VARCHAR(20) NOT NULL,
    status VARCHAR(20) NOT NULL,
    notes VARCHAR(255) NOT NULL
);

INSERT INTO helpdesk_tickets (ticket, status, notes) VALUES
('TICKET-4118', 'closed', 'Reset admin dashboard password per user request. No further action needed.'),
('TICKET-4471', 'open', 'Legacy telnet diagnostics account on the old switch mgmt host is still enabled for firmware testing (svc_diag / Qa9vLp2x). Flagged for decommission after Q3 audit, not yet actioned.'),
('TICKET-4502', 'closed', 'Printer on 3rd floor jammed again, replaced fuser unit.');
