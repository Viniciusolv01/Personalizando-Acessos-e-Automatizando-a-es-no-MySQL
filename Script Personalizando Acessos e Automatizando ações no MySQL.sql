show databases;
use departaments;

  -- Personalizando acessos com Views
-- 1) View: Número de empregados por departamento e localidade

CREATE VIEW view_num_emp_dep_loc AS
SELECT d.dept_name, d.location, COUNT(e.emp_id) AS num_employees
FROM department d
JOIN employee e ON d.dept_id = e.dept_id
GROUP BY d.dept_name, d.location;


  -- 2) View: Lista de departamentos e seus gerentes
  
  CREATE VIEW view_departments_managers AS
SELECT d.dept_name, e.emp_name AS manager_name
FROM department d
JOIN employee e ON d.manager_id = e.emp_id;

-- 3) View: Projetos com maior número de empregados

CREATE VIEW view_projects_most_employees AS
SELECT p.project_name, COUNT(ep.emp_id) AS num_employees
FROM project p
JOIN employee_project ep ON p.project_id = ep.project_id
GROUP BY p.project_name
ORDER BY num_employees DESC;

-- 4) View: Lista de projetos, departamentos e gerentes

CREATE VIEW view_projects_dept_mgr AS
SELECT p.project_name, d.dept_name, e.emp_name AS manager_name
FROM project p
JOIN department d ON p.dept_id = d.dept_id
JOIN employee e ON d.manager_id = e.emp_id;

-- 5) View: Quais empregados possuem dependentes e se são gerentes

CREATE VIEW view_emps_dependents_mgr AS
SELECT e.emp_name, 
       CASE WHEN d.dep_id IS NOT NULL THEN 'Yes' ELSE 'No' END AS has_dependents,
       CASE WHEN e.is_manager = 1 THEN 'Yes' ELSE 'No' END AS is_manager
FROM employee e
LEFT JOIN dependent d ON e.emp_id = d.emp_id;
-- 6) Criando usuários e definindo permissões

-- Criando usuário gerente
CREATE USER 'gerente'@'localhost' IDENTIFIED BY 'senha123';

-- Permissões para gerente: pode ver as views de employee e departamento
GRANT SELECT ON view_num_emp_dep_loc TO 'gerente'@'localhost';
GRANT SELECT ON view_departments_managers TO 'gerente'@'localhost';
GRANT SELECT ON view_projects_dept_mgr TO 'gerente'@'localhost';

-- Criando usuário employee
CREATE USER 'employee'@'localhost' IDENTIFIED BY 'senha123';

-- Permissões para employee: pode ver apenas informações de projetos
GRANT SELECT ON view_projects_most_employees TO 'employee'@'localhost';



  -- Parte 2 – Criando gatilhos para cenário de e-commerce
-- 1) Trigger de remoção: before delete
-- Objetivo: manter log de exclusão de usuários.


CREATE TABLE log_deleted_users (
    user_id INT,
    deleted_at DATETIME
);

DELIMITER $$

CREATE TRIGGER trg_before_delete_user
BEFORE DELETE ON users
FOR EACH ROW
BEGIN
    INSERT INTO log_deleted_users(user_id, deleted_at)
    VALUES (OLD.user_id, NOW());
END$$

DELIMITER ;
-- 2) Trigger de atualização: before update
-- Objetivo: quando um novo colaborador for inserido ou salário alterado, atualizar salário base.

DELIMITER $$

CREATE TRIGGER trg_before_update_salary
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    IF NEW.salary <> OLD.salary THEN
        SET NEW.base_salary = NEW.salary * 0.9; -- exemplo: salário base 90% do atual
    END IF;
END$$

DELIMITER ;

  