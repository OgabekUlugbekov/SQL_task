------TASK_1----------

CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100)
);

CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category VARCHAR(50),
    price DECIMAL(10, 2)
);

CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    payment_method VARCHAR(50),
    total_amount DECIMAL(10, 2),
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);

CREATE TABLE OrderDetails (
    order_detail_id INT PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Products(product_id)
);


INSERT INTO Customers (customer_id, customer_name) VALUES
(1, 'Ali'),
(2, 'Bahar'),
(3, 'Cem'),
(4, 'Derya'),
(5, 'Emre');

INSERT INTO Products (product_id, product_name, category, price) VALUES
(1, 'Laptop', 'Electronics', 1200.00),
(2, 'Headphones', 'Electronics', 50.00),
(3, 'T-Shirt', 'Clothing', 20.00),
(4, 'Jeans', 'Clothing', 40.00),
(5, 'Book', 'Books', 15.00);

INSERT INTO Orders (order_id, customer_id, order_date, payment_method, total_amount) VALUES
(1, 1, '2025-01-15', 'Card', 1250.00),
(2, 1, '2025-02-20', 'Cash', 20.00),
(3, 2, '2025-03-10', 'PayPal', 55.00),
(4, 3, '2025-04-01', 'Card', 1200.00),
(5, 4, '2025-04-15', 'PayPal', 35.00),
(6, 1, '2025-04-20', 'Card', 40.00);

INSERT INTO OrderDetails (order_detail_id, order_id, product_id, quantity) VALUES
(1, 1, 1, 1),
(2, 1, 2, 1),
(3, 2, 3, 1),
(4, 3, 2, 1),
(5, 3, 5, 1),
(6, 4, 1, 1),
(7, 5, 3, 1),
(8, 5, 5, 1),
(9, 6, 4, 1);

--------------------------------------------------------------11111
SELECT TOP 5 
    p.product_name,
    SUM(od.quantity) as total_quantity_sold,
    SUM(od.quantity * p.price) as total_revenue
FROM Products p
JOIN OrderDetails od ON p.product_id = od.product_id
JOIN Orders o ON od.order_id = o.order_id
WHERE o.order_date >= DATEADD(MONTH, -6, '2025-04-25')
GROUP BY p.product_name
ORDER BY total_revenue DESC;


--------------------------------------------------------------22222
WITH RFM AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        DATEDIFF(DAY, MAX(o.order_date), '2025-04-25') as Recency,
        COUNT(o.order_id) as Frequency,
        SUM(o.total_amount) as Monetary
    FROM Customers c
    LEFT JOIN Orders o ON c.customer_id = o.customer_id
    WHERE o.order_date IS NULL OR o.order_date >= DATEADD(MONTH, -6, '2025-04-25')
    GROUP BY c.customer_id, c.customer_name
)
SELECT 
    customer_name,
    Recency,
    Frequency,
    Monetary,
    NTILE(4) OVER (ORDER BY Recency) as R_Score,
    NTILE(4) OVER (ORDER BY Frequency DESC) as F_Score,
    NTILE(4) OVER (ORDER BY Monetary DESC) as M_Score,
    CONCAT(NTILE(4) OVER (ORDER BY Recency), 
           NTILE(4) OVER (ORDER BY Frequency DESC), 
           NTILE(4) OVER (ORDER BY Monetary DESC)) as RFM_Score
FROM RFM
ORDER BY RFM_Score DESC;


--------------------------------------------------------------33333

SELECT 
    p.category,
    CAST(AVG(o.total_amount) as decimal (10, 2)) as avg_order_value
FROM Products p
JOIN OrderDetails od ON p.product_id = od.product_id
JOIN Orders o ON od.order_id = o.order_id
GROUP BY p.category;

--------------------------------------------------------------44444


SELECT 
    o.payment_method,
    SUM(o.total_amount) as total_revenue,
    CAST(AVG(o.total_amount) as decimal (10,2)) as avg_order_value,
    MIN(o.total_amount) as min_order_value,
    MAX(o.total_amount) as max_order_value
FROM Orders o
GROUP BY o.payment_method;

-----------------------------------------------------------------------------------------------------------------------------------------------------
--TASK_2
-----------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE TransportCities (
    city_id INT PRIMARY KEY,
    city_name VARCHAR(100)
);

CREATE TABLE TransportCustomers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100)
);

CREATE TABLE TransportCompanies (
    company_id INT PRIMARY KEY,
    company_name VARCHAR(100)
);

CREATE TABLE TransportBuses (
    bus_id INT PRIMARY KEY,
    company_id INT,
    capacity INT,
    FOREIGN KEY (company_id) REFERENCES TransportCompanies(company_id)
);

CREATE TABLE TransportRoutes (
    route_id INT PRIMARY KEY,
    departure_city_id INT,
    arrival_city_id INT,
    distance_km INT,
    FOREIGN KEY (departure_city_id) REFERENCES TransportCities(city_id),
    FOREIGN KEY (arrival_city_id) REFERENCES TransportCities(city_id)
);

CREATE TABLE TransportSchedules (
    schedule_id INT PRIMARY KEY,
    route_id INT,
    bus_id INT,
    departure_time DATETIME,
    price DECIMAL(10, 2),
    FOREIGN KEY (route_id) REFERENCES TransportRoutes(route_id),
    FOREIGN KEY (bus_id) REFERENCES TransportBuses(bus_id)
);

CREATE TABLE TransportTickets (
    ticket_id INT PRIMARY KEY,
    customer_id INT,
    schedule_id INT,
    seat_number INT,
    purchase_date DATE,
    status VARCHAR(20), 
    FOREIGN KEY (customer_id) REFERENCES TransportCustomers(customer_id),
    FOREIGN KEY (schedule_id) REFERENCES TransportSchedules(schedule_id)
);


INSERT INTO TransportCities (city_id, city_name) VALUES
(1, 'Istanbul'),
(2, 'Ankara'),
(3, 'Izmir');

INSERT INTO TransportCustomers (customer_id, customer_name) VALUES
(1, 'Ali'),
(2, 'Bahar'),
(3, 'Cem'),
(4, 'Derya'),
(5, 'Emre');

INSERT INTO TransportCompanies (company_id, company_name) VALUES
(1, 'Metro'),
(2, 'Pamukkale'),
(3, 'Ulusoy');

INSERT INTO TransportBuses (bus_id, company_id, capacity) VALUES
(1, 1, 40),
(2, 1, 40),
(3, 2, 50),
(4, 3, 45);

INSERT INTO TransportRoutes (route_id, departure_city_id, arrival_city_id, distance_km) VALUES
(1, 1, 2, 450),
(2, 2, 3, 350), 
(3, 1, 3, 600);

INSERT INTO TransportSchedules (schedule_id, route_id, bus_id, departure_time, price) VALUES
(1, 1, 1, '2025-04-20 08:00:00', 100.00),
(2, 1, 2, '2025-04-21 09:00:00', 110.00),
(3, 2, 3, '2025-04-22 10:00:00', 80.00),
(4, 3, 4, '2025-04-23 11:00:00', 150.00),
(5, 1, 1, '2025-04-24 08:00:00', 100.00);

INSERT INTO TransportTickets (ticket_id, customer_id, schedule_id, seat_number, purchase_date, status) VALUES
(1, 1, 1, 5, '2025-04-15', 'Active'),
(2, 1, 1, 6, '2025-04-15', 'Active'),
(3, 2, 2, 10, '2025-04-16', 'Active'),
(4, 3, 3, 15, '2025-04-17', 'Active'),
(5, 4, 4, 20, '2025-04-18', 'Cancelled'),
(6, 5, 5, 25, '2025-04-19', 'Active'),
(7, 1, 5, 26, '2025-04-19', 'Active');

-----------------------------------------1111111111111111111
WITH Preferred AS (
    SELECT 
        c1.city_name as departure_city,
        c2.city_name as arrival_city,
        COUNT(t.ticket_id) as ticket_count
    FROM TransportTickets t
    JOIN TransportSchedules s ON t.schedule_id = s.schedule_id
    JOIN TransportRoutes r ON s.route_id = r.route_id
    JOIN TransportCities c1 ON r.departure_city_id = c1.city_id
    JOIN TransportCities c2 ON r.arrival_city_id = c2.city_id
    WHERE t.purchase_date >= DATEADD(MONTH, -3, '2025-04-25')
    GROUP BY c1.city_name, c2.city_name
)
SELECT 
    departure_city,
    arrival_city,
    ticket_count,
    (ticket_count * 100.0 / SUM(ticket_count) OVER ()) as percentage
FROM Preferred
ORDER BY ticket_count DESC;

-------------------------------------------22222222222222
SELECT 
    c.company_name,
    AVG(s.price) as avg_ticket_price,
    SUM(s.price) as total_revenue,
    (COUNT(t.ticket_id) * 100.0 / SUM(b.capacity)) as occupancy_rate
FROM TransportCompanies c
JOIN TransportBuses b ON c.company_id = b.company_id
JOIN TransportSchedules s ON b.bus_id = s.bus_id
LEFT JOIN TransportTickets t ON s.schedule_id = t.schedule_id AND t.status = 'Active'
GROUP BY c.company_name;

-------------------------------------333333333333333333
WITH Trips AS (
    SELECT 
        c.customer_name,
        COUNT(t.ticket_id) as trip_count
    FROM TransportCustomers c
    LEFT JOIN TransportTickets t ON c.customer_id = t.customer_id
    WHERE t.status = 'Active'
    GROUP BY c.customer_name
)
SELECT 
    customer_name,
    trip_count,
    CASE 
        WHEN trip_count = 1 THEN '1 Trip'
        WHEN trip_count = 2 THEN '2 Trips'
        ELSE 'More than 2 Trips'
    END as trip_category
FROM Trips
ORDER BY trip_count DESC;




-----------------------------------------------------------------------------------------------------------------------------------------------------
--TASK_3
-----------------------------------------------------------------------------------------------------------------------------------------------------

CREATE TABLE SocialMediaUsers (
    user_id INT PRIMARY KEY,
    username VARCHAR(100),
    follower_count INT,
    following_count INT
);

CREATE TABLE SocialMediaPosts (
    post_id INT PRIMARY KEY,
    user_id INT,
    post_date DATE,
    content VARCHAR(500),
    likes INT,
    comments INT,
    FOREIGN KEY (user_id) REFERENCES SocialMediaUsers(user_id)
);

CREATE TABLE SocialMediaFollows (
    follow_id INT PRIMARY KEY,
    follower_id INT,
    followed_id INT,
    follow_date DATE,
    FOREIGN KEY (follower_id) REFERENCES SocialMediaUsers(user_id),
    FOREIGN KEY (followed_id) REFERENCES SocialMediaUsers(user_id)
);

INSERT INTO SocialMediaUsers (user_id, username, follower_count, following_count) VALUES
(1, 'Ali', 12000, 300),
(2, 'Bahar', 15000, 500),
(3, 'Cem', 8000, 200),
(4, 'Derya', 500, 100),
(5, 'Emre', 2000, 150);

INSERT INTO SocialMediaPosts (post_id, user_id, post_date, content, likes, comments) VALUES
(1, 1, '2025-04-15', 'Great day!', 500, 50),
(2, 1, '2025-04-20', 'Loving this!', 600, 70),
(3, 2, '2025-04-16', 'New post!', 800, 100),
(4, 3, '2025-04-17', 'Hello world!', 300, 20),
(5, 4, '2025-04-18', 'My first post', 50, 5),
(6, 5, '2025-04-19', 'Check this out!', 150, 15),
(7, 1, '2025-04-21', 'Another post', 700, 80);

INSERT INTO SocialMediaFollows (follow_id, follower_id, followed_id, follow_date) VALUES
(1, 2, 1, '2025-04-01'),
(2, 3, 1, '2025-04-02'),
(3, 4, 1, '2025-04-03'),
(4, 5, 1, '2025-04-04'),
(5, 1, 2, '2025-04-05'),
(6, 3, 2, '2025-04-06'),
(7, 4, 2, '2025-04-07'),
(8, 1, 3, '2025-04-08'),
(9, 2, 3, '2025-04-09'),
(10, 5, 4, '2025-04-10');



-----------------------------------------1111111111111111
WITH u_engage AS (
    SELECT 
        u.username,
        u.follower_count,
        SUM(p.likes + p.comments) as total_interactions,
        (SUM(p.likes + p.comments) * 100.0 / u.follower_count) as engagement_rate
    FROM SocialMediaUsers u
    LEFT JOIN SocialMediaPosts p ON u.user_id = p.user_id
    GROUP BY u.username, u.follower_count
)
SELECT 
    username,
    follower_count,
    total_interactions,
    engagement_rate
FROM u_engage
ORDER BY engagement_rate DESC;


-----------------------------------------22222222222222222222

WITH u_engage AS (
    SELECT 
        u.username,
        u.follower_count,
        SUM(p.likes + p.comments) as total_interactions,
        (SUM(p.likes + p.comments) * 100.0 / u.follower_count) as engagement_rate
    FROM SocialMediaUsers u
    LEFT JOIN SocialMediaPosts p ON u.user_id = p.user_id
    GROUP BY u.username, u.follower_count
)
SELECT 
    username,
    follower_count,
    engagement_rate
FROM u_engage
WHERE follower_count > 10000 AND engagement_rate > 5
ORDER BY engagement_rate DESC;


--------------------------------------3333333333333333333333

SELECT 
    u.username,
    p.content,
    p.post_date,
    (p.likes + p.comments) as total_interactions,
    p.likes as like_count,
    p.comments as comment_count
FROM SocialMediaPosts p
JOIN SocialMediaUsers u ON p.user_id = u.user_id
ORDER BY total_interactions DESC;

-------------------------------------444444444444444444444

SELECT 
    DATEPART(WEEK, p.post_date) as week_number,
    COUNT(p.post_id) as post_count,
    SUM(p.likes) as total_likes
FROM SocialMediaPosts p
WHERE p.post_date >= DATEADD(WEEK, -4, '2025-04-25')
GROUP BY DATEPART(WEEK, p.post_date)
ORDER BY week_number;

--------------------------------------55555555555555555

WITH ActiveFollowers AS (
    SELECT 
        f.followed_id,
        COUNT(f.follower_id) as active_followers
    FROM SocialMediaFollows f
    JOIN SocialMediaPosts p ON f.follower_id = p.user_id
    WHERE p.post_date >= DATEADD(MONTH, -1, '2025-04-25')
    GROUP BY f.followed_id
),
TotalFollowers AS (
    SELECT 
        u.user_id,
        u.username,
        u.follower_count as total_followers,
        COALESCE(af.active_followers, 0) as active_followers
    FROM SocialMediaUsers u
    LEFT JOIN ActiveFollowers af ON u.user_id = af.followed_id
)
SELECT 
    username,
    total_followers,
    active_followers,
    (total_followers - active_followers) as ghost_followers,
    CASE 
        WHEN total_followers > 0 THEN (active_followers * 100.0 / total_followers)
        ELSE 0
    END as active_follower_ratio,
    CASE 
        WHEN total_followers > 0 THEN ((total_followers - active_followers) * 100.0 / total_followers)
        ELSE 0
    END as ghost_follower_ratio
FROM TotalFollowers;



-----------------------------------------------------------------------------------------------------------------------------------------------------
--TASK_4 
-----------------------------------------------------------------------------------------------------------------------------------------------------
CREATE TABLE CreditAnalysisCustomers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    monthly_salary DECIMAL(10, 2),
    monthly_expense DECIMAL(10, 2),
    risk_level VARCHAR(20) DEFAULT 'Low' 
);

CREATE TABLE CreditAnalysisLoans (
    loan_id INT PRIMARY KEY,
    customer_id INT,
    loan_amount DECIMAL(10, 2),
    interest_rate DECIMAL(5, 2),
    loan_date DATE,
    status VARCHAR(20), 
    FOREIGN KEY (customer_id) REFERENCES CreditAnalysisCustomers(customer_id)
);

CREATE TABLE CreditAnalysisPayments (
    payment_id INT PRIMARY KEY,
    loan_id INT,
    payment_amount DECIMAL(10, 2),
    payment_date DATE,
    FOREIGN KEY (loan_id) REFERENCES CreditAnalysisLoans(loan_id)
);

INSERT INTO CreditAnalysisCustomers (customer_id, customer_name, monthly_salary, monthly_expense, risk_level) VALUES
(1, 'Ali', 5000.00, 3000.00, 'Low'),
(2, 'Bahar', 7000.00, 6000.00, 'Medium'),
(3, 'Cem', 4000.00, 3500.00, 'High'),
(4, 'Derya', 6000.00, 2000.00, 'Low'),
(5, 'Emre', 3000.00, 2500.00, 'Medium');

INSERT INTO CreditAnalysisLoans (loan_id, customer_id, loan_amount, interest_rate, loan_date, status) VALUES
(1, 1, 10000.00, 5.00, '2025-01-15', 'Active'),
(2, 1, 5000.00, 4.50, '2025-02-20', 'Paid'),
(3, 2, 15000.00, 6.00, '2025-03-10', 'Active'),
(4, 3, 8000.00, 7.00, '2025-04-01', 'Active'),
(5, 4, 20000.00, 4.00, '2025-04-15', 'Active'),
(6, 5, 3000.00, 5.50, '2025-04-20', 'Active');

INSERT INTO CreditAnalysisPayments (payment_id, loan_id, payment_amount, payment_date) VALUES
(1, 1, 2000.00, '2025-02-15'),
(2, 1, 2000.00, '2025-03-15'),
(3, 2, 5000.00, '2025-03-20'),
(4, 3, 3000.00, '2025-04-10'),
(5, 4, 1000.00, '2025-04-20'),
(6, 5, 5000.00, '2025-04-22');


-------------------------------------------11111111111111

SELECT 
    c.customer_id,
    c.customer_name,
    COUNT(l.loan_id) as loan_count,
    SUM(l.loan_amount) as total_loan_amount,
    (c.monthly_salary - c.monthly_expense) as monthly_profit,
    CASE 
        WHEN (c.monthly_salary - c.monthly_expense) > 2000 THEN 'High Reliability'
        WHEN (c.monthly_salary - c.monthly_expense) BETWEEN 1000 AND 2000 THEN 'Medium Reliability'
        ELSE 'Low Reliability'
    END as reliability
FROM CreditAnalysisCustomers c
LEFT JOIN CreditAnalysisLoans l ON c.customer_id = l.customer_id
WHERE l.loan_date <= '2025-04-25'
GROUP BY c.customer_id, c.customer_name, c.monthly_salary, c.monthly_expense
ORDER BY total_loan_amount DESC;

---------------------------------------------222222222222222222
SELECT 
    c.customer_name,
    c.monthly_salary,
    c.monthly_expense,
    (c.monthly_salary - c.monthly_expense) as monthly_profit,
    SUM(l.loan_amount) as total_loan_amount,
    CASE 
        WHEN (c.monthly_salary - c.monthly_expense) > (SUM(l.loan_amount) * 0.3) THEN 'Approve Loan'
        WHEN (c.monthly_salary - c.monthly_expense) BETWEEN (SUM(l.loan_amount) * 0.1) AND (SUM(l.loan_amount) * 0.3) THEN 'Review'
        ELSE 'Reject Loan'
    END as loan_decision
FROM CreditAnalysisCustomers c
LEFT JOIN CreditAnalysisLoans l ON c.customer_id = l.customer_id
WHERE l.loan_date >= DATEADD(MONTH, -3, '2025-04-25')
GROUP BY c.customer_name, c.monthly_salary, c.monthly_expense
ORDER BY monthly_profit DESC;	

------------------------------------------3333333333333333333333

SELECT 
    c.risk_level,
    AVG(l.loan_amount) as avg_loan_amount,
    AVG(l.interest_rate) as avg_interest_rate,
    SUM(p.payment_amount) as total_payments
FROM CreditAnalysisCustomers c
LEFT JOIN CreditAnalysisLoans l ON c.customer_id = l.customer_id
LEFT JOIN CreditAnalysisPayments p ON l.loan_id = p.loan_id
GROUP BY c.risk_level;


-----------------------------------------44444444444444444444444
WITH Risk_G AS (
    SELECT 
        c.customer_id,
        c.customer_name,
        c.risk_level,
        SUM(l.loan_amount) as total_loan_amount
    FROM CreditAnalysisCustomers c
    LEFT JOIN CreditAnalysisLoans l ON c.customer_id = l.customer_id
    GROUP BY c.customer_id, c.customer_name, c.risk_level
)
SELECT 
    risk_level,
    COUNT(customer_id) as customer_count,
    SUM(total_loan_amount) as total_loan_amount,
    AVG(total_loan_amount) as avg_loan_amount
FROM Risk_G
GROUP BY risk_level;


-----------------------------------------------------------------------------------------------------------------------------------------------------
--TASK_5 
-----------------------------------------------------------------------------------------------------------------------------------------------------



CREATE TABLE UniversityDepartments (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(100)
);

CREATE TABLE UniversityStudents (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100),
    department_id INT,
    gpa DECIMAL(3, 2),
    enrollment_date DATE,
    FOREIGN KEY (department_id) REFERENCES UniversityDepartments(department_id)
);

CREATE TABLE UniversityCourses (
    course_id INT PRIMARY KEY,
    course_name VARCHAR(100),
    department_id INT,
    credits INT,
    deadline_date DATE,
    FOREIGN KEY (department_id) REFERENCES UniversityDepartments(department_id)
);

CREATE TABLE UniversityEnrollments (
    enrollment_id INT PRIMARY KEY,
    student_id INT,
    course_id INT,
    semester VARCHAR(20),
    grade DECIMAL(4, 1),
    status VARCHAR(20), 
    FOREIGN KEY (student_id) REFERENCES UniversityStudents(student_id),
    FOREIGN KEY (course_id) REFERENCES UniversityCourses(course_id)
);

INSERT INTO UniversityDepartments (department_id, department_name) VALUES
(1, 'Computer Science'),
(2, 'Mathematics'),
(3, 'Physics');

INSERT INTO UniversityStudents (student_id, student_name, department_id, gpa, enrollment_date) VALUES
(1, 'Ali', 1, 3.80, '2024-09-01'),
(2, 'Bahar', 1, 3.50, '2024-09-01'),
(3, 'Cem', 2, 3.20, '2024-09-01'),
(4, 'Derya', 2, 3.90, '2024-09-01'),
(5, 'Emre', 3, 3.00, '2024-09-01'),
(6, 'Fatma', 3, 3.70, '2024-09-01');

INSERT INTO UniversityCourses (course_id, course_name, department_id, credits, deadline_date) VALUES
(1, 'Introduction to Programming', 1, 4, '2025-04-30'),
(2, 'Data Structures', 1, 4, '2025-05-15'),
(3, 'Calculus I', 2, 3, '2025-05-10'),
(4, 'Linear Algebra', 2, 3, '2025-05-20'),
(5, 'Physics I', 3, 4, '2025-05-05');

INSERT INTO UniversityEnrollments (enrollment_id, student_id, course_id, semester, grade, status) VALUES
(1, 1, 1, '2025-Spring', 85.0, 'Passed'),
(2, 1, 2, '2025-Spring', 90.0, 'Passed'),
(3, 2, 1, '2025-Spring', 65.0, 'Failed'),
(4, 2, 2, '2025-Spring', 70.0, 'Passed'),
(5, 3, 3, '2025-Spring', 80.0, 'Passed'),
(6, 3, 4, '2025-Spring', 55.0, 'Failed'),
(7, 4, 3, '2025-Spring', 95.0, 'Passed'),
(8, 4, 4, '2025-Spring', 88.0, 'Passed'),
(9, 5, 5, '2025-Spring', 60.0, 'Failed'),
(10, 6, 5, '2025-Spring', 75.0, 'Passed');


-----------------------------------11111111111111111

GO
CREATE VIEW TOP_GPA AS
SELECT TOP 10
    s.student_id,
    s.student_name,
    d.department_name,
    s.gpa
FROM UniversityStudents s
JOIN UniversityDepartments d ON s.department_id = d.department_id
ORDER BY s.gpa DESC;
GO

SELECT * FROM TOP_GPA;


---------------------------------------------2222222222222222222

SELECT 
    s.student_name,
    c.course_name,
    c.deadline_date,
    CASE 
        WHEN c.deadline_date >= '2025-04-25' THEN 'On Time'
        ELSE 'Missed Deadline'
    END as deadline_status
FROM UniversityStudents s
JOIN UniversityEnrollments e ON s.student_id = e.student_id
JOIN UniversityCourses c ON e.course_id = c.course_id
WHERE e.semester = '2025-Spring'
ORDER BY c.deadline_date;


-----------------------------------------------333333333333333333

SELECT 
    d.department_name,
    AVG(e.grade) as avg_grade,
    SUM(CASE WHEN e.status = 'Passed' THEN 1 ELSE 0 END) * 100.0 / COUNT(e.enrollment_id) as success_rate,
    SUM(CASE WHEN e.status = 'Failed' THEN 1 ELSE 0 END) * 100.0 / COUNT(e.enrollment_id) as fail_rate
FROM UniversityDepartments d
LEFT JOIN UniversityCourses c ON d.department_id = c.department_id
LEFT JOIN UniversityEnrollments e ON c.course_id = e.course_id
GROUP BY d.department_name;

----------------------------------------------------4444444444444444444

SELECT 
    c.course_name,
    d.department_name,
    COUNT(e.enrollment_id) as total_enrollments,
    SUM(CASE WHEN e.status = 'Passed' THEN 1 ELSE 0 END) as passed_count,
    SUM(CASE WHEN e.status = 'Failed' THEN 1 ELSE 0 END) as failed_count,
    SUM(CASE WHEN e.status = 'Passed' THEN 1 ELSE 0 END) * 100.0 / COUNT(e.enrollment_id) as pass_rate,
    SUM(CASE WHEN e.status = 'Failed' THEN 1 ELSE 0 END) * 100.0 / COUNT(e.enrollment_id) as fail_rate
FROM UniversityCourses c
JOIN UniversityDepartments d ON c.department_id = d.department_id
LEFT JOIN UniversityEnrollments e ON c.course_id = e.course_id
GROUP BY c.course_name, d.department_name;




