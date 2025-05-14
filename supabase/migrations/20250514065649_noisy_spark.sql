/*
  # Initial Database Schema for GRADEX

  1. New Tables
    - users
      - id (uuid, primary key)
      - email (text, unique)
      - role (text)
      - display_name (text)
      - created_at (timestamp)
    
    - courses
      - id (uuid, primary key)
      - code (text)
      - name (text)
      - description (text)
      - credits (integer)
      - created_at (timestamp)
    
    - enrollments
      - id (uuid, primary key)
      - student_id (uuid, references users)
      - course_id (uuid, references courses)
      - grade (text)
      - percentage (numeric)
      - status (text)
      - created_at (timestamp)
    
    - faculty_assignments
      - id (uuid, primary key)
      - faculty_id (uuid, references users)
      - course_id (uuid, references courses)
      - created_at (timestamp)

  2. Security
    - Enable RLS on all tables
    - Add policies for data access based on user roles
*/

-- Users table
CREATE TABLE users (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email text UNIQUE NOT NULL,
  role text NOT NULL CHECK (role IN ('admin', 'faculty', 'student')),
  display_name text NOT NULL,
  created_at timestamptz DEFAULT now()
);

-- Courses table
CREATE TABLE courses (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  code text NOT NULL UNIQUE,
  name text NOT NULL,
  description text,
  credits integer NOT NULL CHECK (credits > 0),
  created_at timestamptz DEFAULT now()
);

-- Enrollments table
CREATE TABLE enrollments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  student_id uuid REFERENCES users(id) ON DELETE CASCADE,
  course_id uuid REFERENCES courses(id) ON DELETE CASCADE,
  grade text CHECK (grade IN ('A+', 'A', 'A-', 'B+', 'B', 'B-', 'C+', 'C', 'C-', 'D+', 'D', 'F')),
  percentage numeric CHECK (percentage >= 0 AND percentage <= 100),
  status text NOT NULL CHECK (status IN ('enrolled', 'completed', 'withdrawn')),
  created_at timestamptz DEFAULT now(),
  UNIQUE(student_id, course_id)
);

-- Faculty assignments table
CREATE TABLE faculty_assignments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  faculty_id uuid REFERENCES users(id) ON DELETE CASCADE,
  course_id uuid REFERENCES courses(id) ON DELETE CASCADE,
  created_at timestamptz DEFAULT now(),
  UNIQUE(faculty_id, course_id)
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE courses ENABLE ROW LEVEL SECURITY;
ALTER TABLE enrollments ENABLE ROW LEVEL SECURITY;
ALTER TABLE faculty_assignments ENABLE ROW LEVEL SECURITY;

-- RLS Policies

-- Users policies
CREATE POLICY "Users can view their own data" ON users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Admins can manage all users" ON users
  USING (EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  ));

-- Courses policies
CREATE POLICY "Anyone can view courses" ON courses
  FOR SELECT USING (true);

CREATE POLICY "Admins can manage courses" ON courses
  USING (EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  ));

-- Enrollments policies
CREATE POLICY "Students can view their own enrollments" ON enrollments
  FOR SELECT USING (auth.uid() = student_id);

CREATE POLICY "Faculty can view their course enrollments" ON enrollments
  FOR SELECT USING (EXISTS (
    SELECT 1 FROM faculty_assignments
    WHERE faculty_id = auth.uid() AND course_id = enrollments.course_id
  ));

CREATE POLICY "Admins can manage all enrollments" ON enrollments
  USING (EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  ));

-- Faculty assignments policies
CREATE POLICY "Faculty can view their assignments" ON faculty_assignments
  FOR SELECT USING (auth.uid() = faculty_id);

CREATE POLICY "Admins can manage faculty assignments" ON faculty_assignments
  USING (EXISTS (
    SELECT 1 FROM users WHERE id = auth.uid() AND role = 'admin'
  ));