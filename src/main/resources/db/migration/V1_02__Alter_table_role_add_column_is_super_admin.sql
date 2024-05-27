ALTER TABLE role ADD COLUMN is_super_admin BOOLEAN DEFAULT FALSE;

DELIMITER //

CREATE TRIGGER check_unique_super_admin
    BEFORE INSERT ON role
    FOR EACH ROW
BEGIN
    DECLARE super_admin_count INT DEFAULT 0;
    IF NEW.is_super_admin = 1 THEN
    SELECT COUNT(*) INTO super_admin_count FROM role WHERE is_super_admin = 1;
    IF super_admin_count >= 1 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Only one super admin is allowed.';
END IF;
END IF;
END //

DELIMITER ;

INSERT INTO user(id, username, password, email, full_name, avatar)
VALUES (UNHEX(REPLACE(UUID(), '-', '')), 'superadmin', SHA2('123secure@Password', 256), 'superadmin123@gmail.com', 'Super Admin', '');

SET @super_admin_role_id = (SELECT id FROM role WHERE name = 'SUPER_ADMIN');

INSERT INTO user_role(user_id, role_id)
VALUES ((SELECT id FROM user WHERE username = 'superadmin'), @super_admin_role_id);
