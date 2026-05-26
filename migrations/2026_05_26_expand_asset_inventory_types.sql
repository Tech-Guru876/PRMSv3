-- ============================================================================
-- Migration: Expand Asset and Inventory Type Master Data
-- Purpose: Seed additional Asset Database Type and Inventory Database Type
--          classifications requested by operations.
-- ============================================================================

SET FOREIGN_KEY_CHECKS = 0;

-- Asset Database Type classifications
INSERT INTO `asset_types` (`type_code`, `type_name`, `description`, `sort_order`, `is_active`) VALUES
('HW_COMPUTING', 'IT Hardware - Computing', 'Mainframes, Blade Servers, Rack Servers, Tower Servers, Workstations, Desktop PCs, Laptops, Tablets, Smartphones, Thin Clients.', 101, 1),
('HW_NET_STORAGE', 'IT Hardware - Networking & Storage', 'Network Attached Storage (NAS), Storage Area Networks (SAN), Network Switches, Routers, Hardware Firewalls, Wireless Access Points, Modems, Load Balancers, Fiber Optic Transceivers.', 102, 1),
('HW_PERIPH_AV', 'IT Hardware - Peripherals & AV', 'Laser Printers, Inkjet Printers, 3D Printers, Plotters, Scanners, Copiers, Projectors, Interactive Whiteboards, Monitors, KVM Switches, Uninterruptible Power Supplies (UPS), DSLR Cameras, Video Cameras, PA Systems, Microphones.', 103, 1),
('HW_SPECIAL_SEC', 'IT Hardware - Specialized/Security', 'Biometric Scanners, Barcode Scanners, RFID Readers, Point of Sale (POS) Terminals, DVR/NVR Systems, Security Cameras (CCTV/IP).', 104, 1),
('SW_INTANGIBLES', 'Software & Intangibles', 'ERP Platform Licenses, CRM Licenses, HRIS Platforms, Operating System Licenses, Database Management Systems (DBMS), CAD Software, Proprietary Source Code, Patents, Trademarks, Copyrights, Domain Names, SSL Certificates.', 105, 1),
('FURN_SEAT_DESK', 'Furniture - Seating & Desks', 'Executive Desks, Standing Desks, Cubicle Partitions, Drafting Tables, Conference Tables, Ergonomic Task Chairs, Conference Chairs, Reception Seating, Sofas, Breakroom Seating.', 106, 1),
('FURN_STORE_FIX', 'Furniture - Storage & Fixtures', 'Lateral Filing Cabinets, Vertical Filing Cabinets, Bookcases, Storage Lockers, Credenzas, Safes, Whiteboards, Bulletin Boards, Window Treatments, High-Value Artwork/Decor.', 107, 1),
('FAC_BUILD_EQUIP', 'Facilities & Building Equipment', 'HVAC Units, Chillers, Boilers, Air Handlers, Exhaust Fans, Standby Generators, Portable Generators, Solar Panels, Wind Turbines, Water Heaters, Sump Pumps, Water Filtration Systems, Fire Alarm Control Panels, Turnstiles, Elevators, Escalators, Illuminated Signage, Commercial Soap Dispensers.', 108, 1),
('MACH_PROCESS', 'Machinery & Industrial - Processing', 'Conveyor Belts, Packaging Machines, Palletizers, Industrial Mixers, Industrial Ovens, Centrifuges, Heavy-Duty Transformers.', 109, 1),
('MED_LAB_EQUIP', 'Medical & Laboratory Equipment', 'Electron Microscopes, Optical Microscopes, Spectrophotometers, Autoclaves, Fume Hoods, Biosafety Cabinets, Incubators, Ultra-Low Temp Refrigerators, Chromatography Systems (HPLC/GC), Defibrillators, X-Ray Machines, MRI Machines, Ultrasound Scanners, Surgical Tables.', 110, 1)
ON DUPLICATE KEY UPDATE
  `type_name` = VALUES(`type_name`),
  `description` = VALUES(`description`),
  `sort_order` = VALUES(`sort_order`),
  `is_active` = VALUES(`is_active`);

-- Inventory Database Type classifications
INSERT INTO `inventory_types` (`type_code`, `type_name`, `description`, `sort_order`, `is_active`) VALUES
('MRO_TOOLS_ABR', 'MRO - Tools & Abrasives', 'Masking Tape, Duct Tape, Electrical Tape, Sandpaper (Various Grits), Grinding Discs, Circular Saw Blades, Band Saw Blades, Drill Bits (Masonry/Wood/Metal), Welding Wire, Solder.', 101, 1),
('MRO_FAC_ELEC', 'MRO - Facilities & Electrical', 'LED Lightbulbs, Fluorescent Tubes, AA Batteries, 9V Batteries, HVAC Air Filters, Water Filters, Extension Cords, Circuit Breakers, Fuses, Wall Outlets, Light Switches.', 102, 1),
('MRO_SAFE_PPE', 'MRO - Safety & PPE', 'Safety Glasses, Goggles, Foam Earplugs, Earmuffs, Hard Hats, Bump Caps, N95 Respirators, Half-Face Respirators, Nitrile Gloves, Leather Work Gloves, Cut-Resistant Gloves, High-Vis Safety Vests, Steel-Toe Boots, Fall Protection Harnesses, First Aid Kits.', 103, 1),
('OFF_PAPER_WRITE', 'Office Consumables - Paper & Writing', 'Printer Paper (Letter/A4), Cardstock, Photo Paper, Toner Cartridges, Inkjet Cartridges, Ballpoint Pens, Gel Pens, Pencils, Highlighters, Dry Erase Markers, Permanent Markers.', 104, 1),
('OFF_ORGANIZATION', 'Office Consumables - Organization', 'Staples, Paperclips, Binder Clips, Push Pins, Rubber Bands, Sticky Notes, Legal Pads, Envelopes, File Folders, Hanging Folders, Ring Binders, Sheet Protectors, Filing Labels, Correction Fluid.', 105, 1),
('PACK_SHIPPING', 'Packaging & Shipping', 'Corrugated Cardboard Boxes (Various Dimensions), Poly Mailers, Bubble Mailers, Packing Peanuts, Bubble Wrap Rolls, Kraft Paper Rolls, Shrink Wrap, Stretch Film, Wood Pallets, Plastic Pallets, Plastic Strapping, Packing Tape, Shipping Labels, Edge Protectors.', 106, 1),
('RAW_AGRI_TEXT', 'Raw Materials - Agricultural & Textiles', 'Cotton Yarn, Silk, Wool, Polyester Fabric, Nylon Fabric, Leather, Hardwood Lumber, Softwood Lumber, Plywood, MDF, Wheat, Corn, Sugar, Coffee Beans.', 107, 1),
('MRO_FASTENERS', 'MRO (Maintenance, Repair, Ops) - Fasteners', 'Wood Screws, Machine Screws, Sheet Metal Screws, Nails, Hex Bolts, Carriage Bolts, Hex Nuts, Lock Washers, Flat Washers, Rivets, Drywall Anchors.', 108, 1),
('MRO_HW_MECH', 'MRO - Hardware & Mechanical', 'Hinges, Drawer Glides, Door Handles, Padlocks, Deadbolts, Tension Springs, Compression Springs, Ball Bearings, Roller Bearings, Gears, V-Belts, Timing Belts, Pulleys, Sprockets.', 109, 1),
('MRO_JANITORIAL', 'MRO - Janitorial Supplies', '4% Liquid Bleach (4% Sun Brite Bleach 4L), 9" Jumbo Tissue, 16oz Industrial Mop, 24x33 Garbage Bag BLK 14MIC, 30L Metal Garbage Bin, 32oz Professional Spray Bottle, 38x60 Garbage Bag BLK 17MIC, 4oz Toss in Deodorizer Blocks (Pink), Air Freshener Spray variants, All-Purpose Cleaner (Multipurpose Soap 4L), Anti-Bacteria Soap (4L), Bleach, Brooms, Bulk Instant Hand Sanitizer (4L), Color-Coded Microfibre Cloths, Dishwashing Liquid (4L), Domestic Mops (18"), Domestic Plunger, Festival Broom W/Metal, Floor Wax, Glass Cleaner, Hand Sanitizer, Hand Soap, Heavy Duty Garbage Bags, Industrial Disinfectants, Mop Heads, Paper Towels, Porcelain Cleaner, ScotchBrite W Sponge, Sponges, Toilet Bowl Cleaner (1L), Toilet Brush Set Beige, Toilet Paper, Trash Bags (Various Gallon Sizes), Waste Baskets & Lids, Wooden IND Stick W/Plastic Bottom.', 110, 1)
ON DUPLICATE KEY UPDATE
  `type_name` = VALUES(`type_name`),
  `description` = VALUES(`description`),
  `sort_order` = VALUES(`sort_order`),
  `is_active` = VALUES(`is_active`);

SET FOREIGN_KEY_CHECKS = 1;

SELECT COUNT(*) AS asset_types_total FROM `asset_types`;
SELECT COUNT(*) AS inventory_types_total FROM `inventory_types`;
