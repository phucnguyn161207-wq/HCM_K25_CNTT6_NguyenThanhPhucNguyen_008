CREATE DATABASE football_management;
USE football_management;
-- DROP DATABASE football_management;

-- Phần 1
-- Bảng teams 
CREATE TABLE teams(
    team_id INT PRIMARY KEY AUTO_INCREMENT,
    team_name VARCHAR(100) NOT NULL,
    founded_year YEAR NOT NULL,
    stadium VARCHAR(100) NOT NULL,
    ranking_position INT DEFAULT 0
);

-- Bảng coaches
CREATE TABLE coaches(
    coach_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    nationality VARCHAR(50) NOT NULL,
    experience_years INT DEFAULT 0,
    team_id INT,
    FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

-- Bảng players
CREATE TABLE players(
    player_id INT PRIMARY KEY AUTO_INCREMENT,
    full_name VARCHAR(100) NOT NULL,
    jersey_number INT NOT NULL,
    position VARCHAR(50) NOT NULL,
    salary DECIMAL(12,2) NOT NULL CHECK(salary > 0),
    team_id INT,
    FOREIGN KEY (team_id) REFERENCES teams(team_id)
);

-- Bảng matches
CREATE TABLE matches(
    match_id INT PRIMARY KEY AUTO_INCREMENT,
    home_team_id INT,
    away_team_id INT,
    match_date DATETIME NOT NULL,
    stadium VARCHAR(100) NOT NULL,
    match_status VARCHAR(30) DEFAULT 'Scheduled',
    win_team_id INT,
    
    FOREIGN KEY (home_team_id) REFERENCES teams(team_id),
    FOREIGN KEY (away_team_id) REFERENCES teams(team_id)
);

-- Bảng player_statistics
CREATE TABLE player_statistics(
    stat_id INT PRIMARY KEY AUTO_INCREMENT,
    player_id INT,
    match_id INT,
    goals INT DEFAULT 0,
    assists INT DEFAULT 0,
    yellow_cards INT DEFAULT 0,
    rating_score DECIMAL(3,1) DEFAULT 0,
    FOREIGN KEY (player_id) REFERENCES players(player_id),
    FOREIGN KEY (match_id) REFERENCES matches(match_id)
);

-- Phần 2
-- Câu 1
INSERT INTO teams VALUES
(1, 'Manchester City', 1901, 'Etihad Stadium', 1),
(2, 'Real Madrid', 1902, 'Santiago Bernabeu', 2),
(3, 'Hanoi FC', 2006, 'Hang Đay Stadium', 3),
(4, 'Saigon United', 2015, 'Thong Nhat Stadium', 5),
(5, 'Thép xanh Nam Định', 1979, 'Thiên Trường Stadium', 10);

INSERT INTO coaches VALUES
(1, 'Pep Guardiola', 'Spanish', 15, 1),
(2, 'Carlo Ancelotti', 'Italian', 25, 2),
(3, 'Chu Đình Nghiêm', 'Vietnamese', 12, 3),
(4, 'Alexandre Polking', 'German-Brazilian', 10, 4),
(5, 'Park Hang-seo', 'Korean', 30, 5);

INSERT INTO players VALUES
(1, 'Erling Haaland', 9, 'Forward', 450000000, 1),
(2, 'Kevin De Bruyne', 17, 'Midfielder', 400000000, 1),
(3, 'Nguyễn Quang Hải', 19, 'Midfielder', 60000000, 3),
(4, 'Kylian Mbappe', 7, 'Forward', 500000000, 2),
(5, 'Nguyễn Quang Hải', 10, 'Forward', 55000000, 3);

INSERT INTO matches VALUES
(1, 1, 2, '2026-05-10 19:00', 'Etihad Stadium', 'Finished', 1),
(2, 3, 4, '2026-05-12 18:30', 'Hang Đay Stadium', 'Finished', 3),
(3, 5, 1, '2026-05-15 20:00', 'Thiên Trường Stadium', 'Scheduled', 5),
(4, 2, 3, '2026-05-20 21:00', 'Santiago Bernabeu', 'Scheduled', 2),
(5, 4, 5, '2026-05-25 17:00', 'Thong Nhat Stadium', 'Scheduled', 5);

INSERT INTO player_statistics VALUES
(1, 1, 1, 2, 1, 0, 9.5),
(2, 4, 1, 1, 0, 1, 8.2),
(3, 3, 2, 0, 2, 0, 8.5),
(4, 5, 2, 3, 0, 0, 9.0),
(5, 1, 4, 0, 0, 3, 5.0);

-- Câu 2: Tăng 15% lương các cầu thủ có vị trí Forward và rating_score trung bình lớn hơn 8.0
SET SQL_SAFE_UPDATES = 0;
UPDATE players 
SET salary = salary * 1.15
WHERE position = 'Forward' 
AND player_id IN (
      SELECT player_id 
      FROM player_statistics 
      GROUP BY player_id 
      HAVING AVG(rating_score) > 8.0
  );

-- Xóa các bản ghi trong player_statistics thỏa mãn có số thẻ vàng lớn hơn 2
DELETE FROM player_statistics
WHERE yellow_cards > 2;

-- Phần 3
-- Câu 1: Liệt kê tt cầu thủ có lương > 50000000 hoặc position là 'Midfielder'
SELECT full_name, jersey_number, position
FROM players
WHERE salary > 50000000 OR position = 'Midfielder';

-- Câu 2: Liệt kê tt đội bóng có thứ hạng từ 1 đến 5 và tên sân vận động bắt đầu bằng chữ "s"
SELECT team_name, stadium
FROM teams
WHERE ranking_position BETWEEN 1 AND 5
AND stadium LIKE 'S%';

-- Câu 3: Liệt kê tt trận đấu được xếp theo ngày thi đấu mới nhất và chỉ hiển thị 3 trận ở trang thứ hai
SELECT match_id, stadium, match_date
FROM matches
ORDER BY match_date DESC
LIMIT 3 OFFSET 3;

-- Phần 4
-- Câu 1: Liệt kê cầu thủ với dữ liệu lấy từ bảng liên quan trong hệ thống
SELECT p.full_name, t.team_name, ps.goals, ps.assists
FROM players AS p
INNER JOIN teams AS t
ON p.team_id = t.team_id
INNER JOIN player_statistics ps
ON p.player_id = ps.player_id;

-- Câu 2: Liệt kê tt đội bóng gồm: tên đội, tổng bản thắng của cầu thủ thuộc đội đó chỉ hiển thị những đội có tổng số bàn thắng lớn hơn 10
SELECT t.team_name, SUM(ps.goals) AS total_goals
FROM teams AS t
INNER JOIN players AS p
ON t.team_id = p.team_id
INNER JOIN player_statistics AS ps
ON p.player_id = ps.player_id
GROUP BY t.team_id, t.team_name
HAVING SUM(ps.goals) > 10;

-- Câu 3: Liệt kê tt cầu thủ có mức lương cao nhất hệ thống
SELECT player_id, full_name, salary
FROM players
WHERE salary = (SELECT MAX(salary) FROM players);

-- Phần 5:
-- Câu 1: Tạo chỉ mục trên bảng players dựa trên: position, salary 
CREATE INDEX idx_players_position_salary
ON players(position, salary);

-- Câu 2: Tạo một khung nhìn dữ liệu hiển thị, k tính mức lương bằng 0
CREATE VIEW view_team_salary_summary AS
SELECT t.team_name, COUNT(p.player_id), SUM(p.salary)
FROM teams AS t
INNER JOIN players AS p
ON t.team_id = p.team_id
WHERE p.salary > 0
GROUP BY t.team_id, t.team_name;

-- Phần 6:
-- Câu 1: Viết trigger khi thêm mới bản ghi mà goals > 10 thì tự động tăng lương thêm 5%
DELIMITER //
CREATE TRIGGER trg_increase_salary_after_goal
AFTER INSERT ON player_statistics
FOR EACH ROW
BEGIN
    IF NEW.goals > 10 THEN
        UPDATE players
        SET salary = salary * 1.05
        WHERE player_id = NEW.player_id;
    END IF;
END //
DELIMITER ;

-- Câu 2: 

