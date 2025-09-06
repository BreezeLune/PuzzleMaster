-- MySQL 8.0 schema for PuzzleMaster
-- Charset & engine
SET NAMES utf8mb4;
SET SESSION sql_mode = 'STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

CREATE DATABASE IF NOT EXISTS puzzlemaster DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE puzzlemaster;

-- Users
CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  username VARCHAR(32) NOT NULL,
  email VARCHAR(128) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  failed_logins INT NOT NULL DEFAULT 0,
  locked_until DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uk_users_username (username),
  UNIQUE KEY uk_users_email (email)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Refresh tokens
CREATE TABLE IF NOT EXISTS refresh_tokens (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  token_hash CHAR(64) NOT NULL,
  expires_at DATETIME NOT NULL,
  revoked TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_refresh_token_hash (token_hash),
  KEY idx_refresh_user (user_id),
  CONSTRAINT fk_refresh_user FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Assets (images)
CREATE TABLE IF NOT EXISTS assets (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  owner_user_id BIGINT UNSIGNED NULL,
  file_url VARCHAR(255) NOT NULL,
  thumb_url VARCHAR(255) NULL,
  mime VARCHAR(64) NOT NULL,
  width INT NOT NULL,
  height INT NOT NULL,
  size_bytes INT NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_assets_owner (owner_user_id),
  CONSTRAINT fk_assets_owner FOREIGN KEY (owner_user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Puzzles
CREATE TABLE IF NOT EXISTS puzzles (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  type ENUM('system','custom') NOT NULL,
  owner_user_id BIGINT UNSIGNED NULL,
  name VARCHAR(64) NOT NULL,
  difficulty INT NOT NULL,
  shape ENUM('rect','irregular') NOT NULL DEFAULT 'rect',
  allow_rotation TINYINT(1) NOT NULL DEFAULT 0,
  asset_id BIGINT UNSIGNED NOT NULL,
  status ENUM('active','inactive') NOT NULL DEFAULT 'active',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_puzzles_type_diff_created (type, difficulty, created_at),
  KEY idx_puzzles_owner_created (owner_user_id, created_at),
  CONSTRAINT fk_puzzles_owner FOREIGN KEY (owner_user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT fk_puzzles_asset FOREIGN KEY (asset_id) REFERENCES assets(id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Archives (saves)
CREATE TABLE IF NOT EXISTS archives (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  puzzle_id BIGINT UNSIGNED NOT NULL,
  steps INT NOT NULL,
  duration_sec INT NOT NULL,
  state_json JSON NOT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  deleted_at DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_archives_user_updated (user_id, updated_at),
  CONSTRAINT fk_archives_user FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_archives_puzzle FOREIGN KEY (puzzle_id) REFERENCES puzzles(id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Shares
CREATE TABLE IF NOT EXISTS shares (
  puzzle_id BIGINT UNSIGNED NOT NULL,
  creator_user_id BIGINT UNSIGNED NOT NULL,
  shared_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  status ENUM('on','off') NOT NULL DEFAULT 'on',
  PRIMARY KEY (puzzle_id),
  KEY idx_shares_status_shared (status, shared_at),
  CONSTRAINT fk_shares_puzzle FOREIGN KEY (puzzle_id) REFERENCES puzzles(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_shares_creator FOREIGN KEY (creator_user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Results (finish records)
CREATE TABLE IF NOT EXISTS results (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  puzzle_id BIGINT UNSIGNED NOT NULL,
  difficulty INT NOT NULL,
  steps INT NOT NULL,
  duration_sec INT NOT NULL,
  finished_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_results_rank (puzzle_id, difficulty, duration_sec, steps, finished_at),
  KEY idx_results_user_time (user_id, finished_at),
  CONSTRAINT fk_results_user FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_results_puzzle FOREIGN KEY (puzzle_id) REFERENCES puzzles(id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Best results (per user/puzzle/difficulty)
CREATE TABLE IF NOT EXISTS best_results (
  puzzle_id BIGINT UNSIGNED NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  difficulty INT NOT NULL,
  steps INT NOT NULL,
  duration_sec INT NOT NULL,
  finished_at DATETIME NOT NULL,
  PRIMARY KEY (puzzle_id, user_id, difficulty),
  KEY idx_best_rank (puzzle_id, difficulty, duration_sec, steps, finished_at),
  CONSTRAINT fk_best_user FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_best_puzzle FOREIGN KEY (puzzle_id) REFERENCES puzzles(id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Battle rooms
CREATE TABLE IF NOT EXISTS battle_rooms (
  id CHAR(6) NOT NULL,
  owner_user_id BIGINT UNSIGNED NOT NULL,
  status ENUM('waiting','ready','running','ended','cancelled') NOT NULL DEFAULT 'waiting',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  started_at DATETIME NULL,
  ended_at DATETIME NULL,
  PRIMARY KEY (id),
  CONSTRAINT fk_rooms_owner FOREIGN KEY (owner_user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Battle participants
CREATE TABLE IF NOT EXISTS battle_participants (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  room_id CHAR(6) NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  is_ready TINYINT(1) NOT NULL DEFAULT 0,
  joined_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uk_participant (room_id, user_id),
  CONSTRAINT fk_part_room FOREIGN KEY (room_id) REFERENCES battle_rooms(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_part_user FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Battle progress
CREATE TABLE IF NOT EXISTS battle_progress (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  room_id CHAR(6) NOT NULL,
  user_id BIGINT UNSIGNED NOT NULL,
  progress_pct DECIMAL(5,2) NOT NULL DEFAULT 0.00,
  steps INT NOT NULL DEFAULT 0,
  duration_sec INT NOT NULL DEFAULT 0,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_progress_room_user (room_id, user_id),
  CONSTRAINT fk_prog_room FOREIGN KEY (room_id) REFERENCES battle_rooms(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_prog_user FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- AI tasks
CREATE TABLE IF NOT EXISTS ai_tasks (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  prompt VARCHAR(255) NOT NULL,
  style VARCHAR(32) NULL DEFAULT 'pixel',
  size VARCHAR(16) NULL DEFAULT '512x512',
  status ENUM('pending','done','failed') NOT NULL DEFAULT 'pending',
  asset_id BIGINT UNSIGNED NULL,
  error_msg VARCHAR(255) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_ai_user (user_id, created_at),
  KEY idx_ai_status (status),
  CONSTRAINT fk_ai_user FOREIGN KEY (user_id) REFERENCES users(id)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT fk_ai_asset FOREIGN KEY (asset_id) REFERENCES assets(id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Convenience views (optional)
-- Total wins per user (for global leaderboard)
CREATE OR REPLACE VIEW v_user_total_wins AS
SELECT user_id, COUNT(*) AS total_wins
FROM results
GROUP BY user_id;


