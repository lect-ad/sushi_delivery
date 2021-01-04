USE sushi_delivery;

-- ---------------------
-- Делаем выборку клиентов по возрасту (только из тех, кто возраст указал)
-- ---------------------
SELECT 
    customers.id AS customerID,
    CONCAT(customers.Firstname,
            ' ',
            IFNULL(customers.Lastname,
                    '==Lastname Not Provided==')) AS fullname,
    ROUND(DATEDIFF(NOW(), BirthDate) / 365.25, 0) AS age,
    CASE
        WHEN ROUND(DATEDIFF(NOW(), BirthDate) / 365.25, 0) BETWEEN 0 AND 35 THEN 'Young_people'
        WHEN ROUND(DATEDIFF(NOW(), BirthDate) / 365.25, 0) BETWEEN 36 AND 60 THEN 'Average_age'
        ELSE 'Seniors'
    END AS age_category
FROM
    customers
WHERE
    BirthDate IS NOT NULL
ORDER BY age;

-- ---------------------
-- Выбираем клиентов, у которых больше и меньше всего ВЫПОЛНЕННЫХ заказов
-- (больше 13 и меньше 5)
-- ---------------------
SELECT 
    IF(COUNT(orders.id) > 13,
        'more than 13 orders',
        'less than 5 orders') AS ordersgroup,
    customers.id AS customerID,
    CONCAT(customers.Firstname,
            ' ',
            IFNULL(customers.Lastname,
                    '==Lastname Not Provided==')) AS fullname,
    IFNULL(email, '==Email Not Provided==') AS email,
    phone,
    COUNT(orders.id) AS total_orders_fulfilled
FROM
    customers
        INNER JOIN
    orders ON customers.id = orders.customer
WHERE
    orders.deliveryaddress IS NOT NULL
GROUP BY customers.id
HAVING total_orders_fulfilled NOT BETWEEN 5 AND 13
ORDER BY total_orders_fulfilled DESC;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- --------------------------------
-- Ищем несоответствия фактического типа платежа указанному при заказе
-- и клиентов, у кого таких случаев 3 и более
-- --------------------------------
SELECT 
    orders.customer AS customerID,
    CONCAT(customers.Firstname,
            ' ',
            IFNULL(customers.Lastname,
                    '==Lastname Not Provided==')) AS fullname,
    customers.phone,
    COUNT(orders.PayMethFact) AS payment_mismatches
FROM
    orders
        INNER JOIN
    customers ON orders.Customer = customers.id
WHERE
    orders.PayMethPlan != orders.PayMethFact
GROUP BY orders.customer
HAVING payment_mismatches > 2
ORDER BY payment_mismatches DESC;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- --------------------------------
-- Выясняем, кто из любителей суши является хасководом и к какой возрастной группе он/она относится
-- --------------------------------
SELECT 
    customers.id AS customerID,
    CONCAT(customers.Firstname,
            ' ',
            IFNULL(customers.Lastname,
                    '==Lastname Not Provided==')) AS fullname_of_husky_owner,
    IFNULL(email, '==Email Not Provided==') AS email,
    phone,
    CASE
        WHEN ROUND(DATEDIFF(NOW(), BirthDate) / 365.25, 0) BETWEEN 0 AND 35 THEN 'Young_husky_owner'
        WHEN ROUND(DATEDIFF(NOW(), BirthDate) / 365.25, 0) BETWEEN 36 AND 60 THEN 'Mature_husky_owner'
        WHEN ROUND(DATEDIFF(NOW(), BirthDate) / 365.25, 0) > 60 THEN 'Senior_husky_owner'
        ELSE '==Age_not_Provided=='
    END AS age_category
FROM
    customers
        INNER JOIN
    huskyownershipdict ON huskyownershipdict.id = customers.IsHuskyOwner
WHERE
    huskyownershipdict.HuskyOwnership = 'YES'
ORDER BY DATEDIFF(NOW(), BirthDate);


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- --------------------------------
-- Выясняем, что наиболее популярно в заказах у хасководов
-- --------------------------------
SELECT 
    assortment.Item, COUNT(assortment.Item) AS ordered_times
FROM
    customers
        INNER JOIN
    huskyownershipdict ON huskyownershipdict.id = customers.IsHuskyOwner
        INNER JOIN
    orders ON orders.customer = customers.id
        INNER JOIN
    goodsinorder ON goodsinorder.ForOrder = orders.id
        INNER JOIN
    assortment ON assortment.id = goodsinorder.AssortmentID
WHERE
    huskyownershipdict.HuskyOwnership = 'YES'
        AND orders.DeliveryAddress IS NOT NULL
GROUP BY assortment.Item
ORDER BY ordered_times DESC;

-- И сколько по количеству они заказывают в сравнении с нехасятниками
SELECT 
    IF(huskyownershipdict.HuskyOwnership = 'YES',
        'Husky_owners',
        'Not_husky_owners') AS husky_ownership,
    SUM(assortment.Price) AS total_orders_price,
    COUNT(DISTINCT (orders.id)) AS number_of_orders,
    ROUND(SUM(assortment.Weight) / COUNT(DISTINCT (orders.id)),
            1) AS avg_weight_per_order,
    ROUND(SUM(assortment.Price) / COUNT(DISTINCT (orders.id)),
            2) AS avg_price_per_order
FROM
    customers
        INNER JOIN
    huskyownershipdict ON huskyownershipdict.id = customers.IsHuskyOwner
        INNER JOIN
    orders ON orders.customer = customers.id
        INNER JOIN
    goodsinorder ON goodsinorder.ForOrder = orders.id
        INNER JOIN
    assortment ON assortment.id = goodsinorder.AssortmentID
WHERE
    orders.DeliveryAddress IS NOT NULL
GROUP BY husky_ownership;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- --------------------------------
-- Ищем районы, в которых больше и меньше всех заказов
-- --------------------------------
SELECT 
    citydistrictsdict.district,
    COUNT(orders.DeliveryAddress) AS total_orders
FROM
    orders
        INNER JOIN
    deliveryaddresses ON orders.DeliveryAddress = deliveryaddresses.id
        INNER JOIN
    citydistrictsdict ON deliveryaddresses.CityDistrict = citydistrictsdict.district
GROUP BY district
ORDER BY total_orders DESC;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- --------------------------
-- Ищем, какие товары в каких районах города более популярны
-- --------------------------
SELECT 
    citydistrictsdict.district,
    assortment.item,
    COUNT(goodsinorder.fororder) AS total_orders_of_item_in_district
FROM
    assortment
        INNER JOIN
    goodsinorder ON assortment.id = goodsinorder.AssortmentID
        INNER JOIN
    orders ON goodsinorder.fororder = orders.id
        INNER JOIN
    deliveryaddresses ON orders.deliveryaddress = deliveryaddresses.id
        INNER JOIN
    citydistrictsdict ON deliveryaddresses.citydistrict = citydistrictsdict.district
GROUP BY citydistrictsdict.district , assortment.item
ORDER BY district , total_orders_of_item_in_district DESC;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- --------------------------------
-- Ищем самые "денежные" районы по общей и средней сумме заказов в них
-- --------------------------------
SELECT 
    district,
    SUM(cost_of_order) AS total_district_orders_cost,
    ROUND(AVG(cost_of_order), 2) AS avg_district_orders_cost
FROM
    (SELECT 
        goodsinorder.ForOrder,
            citydistrictsdict.district,
            SUM(assortment.price) AS cost_of_order
    FROM
        goodsinorder
    JOIN assortment ON goodsinorder.AssortmentID = assortment.id
    JOIN orders ON orders.id = goodsinorder.ForOrder
    JOIN deliveryaddresses ON deliveryaddresses.id = orders.DeliveryAddress
    JOIN citydistrictsdict ON citydistrictsdict.district = deliveryaddresses.CityDistrict
    GROUP BY ForOrder) AS sum_per_order
GROUP BY district
ORDER BY total_district_orders_cost DESC;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- --------------------------------
-- Выясняем динамику кол-ва заказов по месяцам
-- --------------------------------
SELECT 
    MONTH(StartTime) AS month_num,
    MONTHNAME(StartTime) AS month,
    COUNT(orders.id) AS number_of_orders
FROM
    orders
        INNER JOIN
    deliverysessions ON orders.DeliverySession = deliverysessions.id
GROUP BY month
ORDER BY month_num;

-- --------------------------------
-- По дням недели
-- --------------------------------
SELECT 
    DAYNAME(StartTime) AS day_of_week,
    COUNT(orders.id) AS number_of_orders
FROM
    orders
        INNER JOIN
    deliverysessions ON orders.DeliverySession = deliverysessions.id
GROUP BY day_of_week
ORDER BY DAYOFWEEK(StartTime);


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- --------------------------------
-- ищем самый (не)популярный метод заказа
-- --------------------------------
SELECT 
    orders.orderedvia AS order_method,
    COUNT(orders.id) AS total_orders
FROM
    orders
GROUP BY order_method
ORDER BY total_orders DESC;

-- ... и оплаты
SELECT 
    PayMethFact AS pay_method, COUNT(orders.id) AS total_orders
FROM
    orders
WHERE
    PayMethFact IS NOT NULL
GROUP BY pay_method
ORDER BY total_orders DESC;


-- --------------------------------
-- Выясняем, кто из курьеров доставил больше заказов и отработал 
-- больше смен (в т.ч. "пустых, без заказов")
-- --------------------------------
SELECT 
    couriers.id AS courier_id,
    CONCAT(FirstName, ' ', LastName) AS courier_fullname,
    COUNT(DISTINCT (couriersshifts.id)) AS total_shifts_worked,
    COUNT(orders.DeliveryAddress) AS total_orders_delivered
FROM
    couriers
        INNER JOIN
    couriersshifts ON couriers.id = couriersshifts.Courier
        LEFT JOIN
    deliverysessions ON couriersshifts.id = deliverysessions.CouriersShift
        LEFT JOIN
    orders ON deliverysessions.id = orders.DeliverySession
GROUP BY couriers.id
ORDER BY total_orders_delivered DESC , total_shifts_worked DESC;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- --------------------------------
-- Выясняем, какие курьеры в каких районах сколько заказов выполнили
-- --------------------------------
SELECT 
    couriers.id,
    CONCAT(couriers.FirstName,
            ' ',
            couriers.LastName) AS couriers_fullname,
    CityDistrict,
    COUNT(orders.DeliveryAddress) AS total_deliveries_in_district
FROM
    couriers
        INNER JOIN
    couriersshifts ON couriers.id = couriersshifts.Courier
        INNER JOIN
    deliverysessions ON couriersshifts.id = deliverysessions.CouriersShift
        INNER JOIN
    orders ON deliverysessions.id = orders.DeliverySession
        INNER JOIN
    deliveryaddresses ON orders.DeliveryAddress = deliveryaddresses.id
GROUP BY couriers_fullname , CityDistrict
ORDER BY couriers.id , total_deliveries_in_district DESC;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- --------------------------------
-- Выясняем, из каких ресторанов в какие районы города сколько заказов доставили
-- --------------------------------
SELECT 
    CONCAT(restaurantsdict.RestaurantAddr,
            ' ',
            restaurantsdict.CityDistrict,
            ' district') AS Restaurant_and_its_district,
    deliveryaddresses.CityDistrict AS delivery_district,
    COUNT(orders.DeliveryAddress) AS total_orders_in_district
FROM
    restaurantsdict
        INNER JOIN
    deliverysessions ON restaurantsdict.id = deliverysessions.Restaurant
        INNER JOIN
    orders ON deliverysessions.id = orders.DeliverySession
        INNER JOIN
    deliveryaddresses ON orders.DeliveryAddress = deliveryaddresses.id
GROUP BY Restaurant_and_its_district , delivery_district
ORDER BY Restaurant_and_its_district , total_orders_in_district DESC;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- --------------------------------
-- Выясняем общее количество выполненных и отмененных заказов
-- --------------------------------
SELECT 
    COUNT(orders.DeliveryAddress) AS total_orders_fulfilled,
    COUNT(orders.id) - COUNT(orders.DeliveryAddress) AS total_orders_canceled
FROM
    orders;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- --------------------------------
-- Выясняем время, прошедшее до отмены заказов от их размещения
-- --------------------------------
SELECT 
    canceled.Order AS order_id,
    TIMEDIFF(canceltime, placetime) AS time_passed_before_cancelling
FROM
    (SELECT 
        orderstatushist.Status,
            orderstatushist.Time AS placetime,
            orderstatushist.Order
    FROM
        orderstatushist
    INNER JOIN orders ON orderstatushist.order = orders.id
    INNER JOIN statusdict ON orderstatushist.Status = statusdict.id
    WHERE
        statusdict.status = 'Placed') AS placed
        INNER JOIN
    (SELECT 
        orderstatushist.Status,
            orderstatushist.Time AS canceltime,
            orderstatushist.Order
    FROM
        orderstatushist
    INNER JOIN orders ON orderstatushist.order = orders.id
    INNER JOIN statusdict ON orderstatushist.Status = statusdict.id
    WHERE
        statusdict.status = 'Canceled') AS canceled ON canceled.Order = placed.Order
ORDER BY time_passed_before_cancelling DESC;

-- --------------------------------
-- И делаем выборку времени, затрачиваемого от размещения заказа до его доставки 
-- --------------------------------
SELECT 
    fulfilled.Order AS order_id,
    TIMEDIFF(delivered, placetime) AS delivery_time
FROM
    (SELECT 
        orderstatushist.Status,
            orderstatushist.Time AS placetime,
            orderstatushist.Order
    FROM
        orderstatushist
    INNER JOIN orders ON orderstatushist.order = orders.id
    INNER JOIN statusdict ON orderstatushist.Status = statusdict.id
    WHERE
        statusdict.status = 'Placed') AS placed
        INNER JOIN
    (SELECT 
        orderstatushist.Status,
            orderstatushist.Time AS delivered,
            orderstatushist.Order
    FROM
        orderstatushist
    INNER JOIN orders ON orderstatushist.order = orders.id
    INNER JOIN statusdict ON orderstatushist.Status = statusdict.id
    WHERE
        statusdict.status = 'Fulfilled') AS fulfilled ON fulfilled.Order = placed.Order
ORDER BY delivery_time DESC;


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- --------------------------------
-- Выясняем неоптимальные сессии доставки с т.зр. логистики.
-- Принимаем в качестве условия 3 и более районов или
-- расстояние более 25 км или
-- продолжительности сессии доставки более 1 часа 50 мин
-- --------------------------------
SELECT 
    deliverysessions.id AS session_id,
    StartTime,
    IF(HOUR(StartTime) BETWEEN 7 AND 22,
        'Day',
        'Night') AS time_of_day,
    TIMEDIFF(EndTime, StartTime) AS session_duration,
    TotalDistance,
    COUNT(DISTINCT (deliveryaddresses.CityDistrict)) AS number_of_districts_in_session
FROM
    deliverysessions
        INNER JOIN
    orders ON deliverysessions.id = orders.DeliverySession
        INNER JOIN
    deliveryaddresses ON deliveryaddresses.id = orders.DeliveryAddress
GROUP BY deliverysessions.id
HAVING number_of_districts_in_session > 2
    OR TotalDistance > 25
    OR session_duration > '01:50:00';


-- ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

-- --------------------------------
-- Делаем выборку транспорта по пробегу и сменам
-- --------------------------------
SELECT 
    transport.id AS transport_id,
    CONCAT(transporttypes.Type,
            ' with Reg/Inv # ',
            transport.Regnum) AS vehicle,
    COUNT(DISTINCT (couriersshifts.id)) AS total_shifts_used,
    SUM(TotalDistance) AS total_kilometrage
FROM
    couriersshifts
        INNER JOIN
    transport ON transport.id = couriersshifts.TransportUsed
        INNER JOIN
    transporttypes ON transporttypes.id = transport.Type
        LEFT JOIN
    deliverysessions ON couriersshifts.id = deliverysessions.CouriersShift
GROUP BY transport.id
ORDER BY total_kilometrage DESC , total_shifts_used DESC;