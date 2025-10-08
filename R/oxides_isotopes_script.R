# Scraper for oxide formulas from the Chemeurope webpage
#  Fully Exploiting the Potential of the Periodic Table through Pattern Recognition Schultz, Emeric. J. Chem. Educ. 2005 82 1649.



library(rvest)
library(stringr)
library(purrr)



full_text <- read_html("https://www.chemeurope.com/en/encyclopedia/Oxide.html") |>
  html_text()

# Oxide list section
section_start <- regexpr("List of all known oxides sorted by oxidation state", full_text)
text_after_section <- substr(full_text, section_start, nchar(full_text))

# First 20000 characters to capture all oxides
text_section <- substr(text_after_section, 1, 20000)

# Formulas are between between parentheses
all_matches <- str_extract_all(text_section, "\\([^)]+\\)")[[1]]

# Only matches with oxygen
oxide_matches <- all_matches[grepl("O", all_matches)]
oxide_formulas <- gsub("[()]", "", oxide_matches)

# Remove oxidation states and non-oxides
oxide_formulas <- oxide_formulas[!grepl("^[IVX]+$", oxide_formulas)]
exclude_patterns <- c("SO4", "MnO4", "NO3", "PO4", "ClO")

for(pattern in exclude_patterns) {
  oxide_formulas <- oxide_formulas[!grepl(pattern, oxide_formulas)]
}


final_oxides <- data.frame(Formula = oxide_formulas)
final_oxides <- final_oxides[order(final_oxides$Formula), , drop = FALSE]
final_oxides <- final_oxides[final_oxides$Formula != "O4",]

# Element symbols column
final_oxides$Element_Symbol <- sapply(final_oxides$Formula, function(formula) {
  elements <- str_extract_all(formula, "[A-Z][a-z]?")[[1]]
  elements <- elements[elements != "O"]
  paste(unique(elements), collapse = ", ")
})

# write.csv(final_oxides, "oxide_formulas.csv", row.names = FALSE)

# Split by element symbol
oxide_list <- split(final_oxides$Formula, final_oxides$Element_Symbol)



# Elements table from ZooMR. Original source is mMass by Martin Strohalm
elements_table <- list(
  Ac = list(name = "Actinium", symbol = "Ac", atomic_number = 89, isotopes = list("227" = list(227.02774700000001, 1.0)), valence = 3),
  Ag = list(name = "Silver", symbol = "Ag", atomic_number = 47, isotopes = list("107" = list(106.90509299999999, 0.51839000000000002), "109" = list(108.90475600000001, 0.48160999999999998)), valence = 1),
  Al = list(name = "Aluminium", symbol = "Al", atomic_number = 13, isotopes = list("27" = list(26.981538440000001, 1.0)), valence = 3),
  Am = list(name = "Americium", symbol = "Am", atomic_number = 95, isotopes = list("241" = list(241.05682289999999, 0.0), "243" = list(243.06137269999999, 1.0)), valence = 3),
  Ar = list(name = "Argon", symbol = "Ar", atomic_number = 18, isotopes = list("40" = list(39.962383123000002, 0.99600299999999997), "36" = list(35.967546280000001, 0.0033649999999999999), "38" = list(37.962732199999998, 0.00063199999999999997)), valence = 0),
  As = list(name = "Arsenic", symbol = "As", atomic_number = 33, isotopes = list("75" = list(74.921596399999999, 1.0)), valence = 3),
  At = list(name = "Astatine", symbol = "At", atomic_number = 85, isotopes = list("210" = list(209.98713100000001, 0.0), "211" = list(210.987481, 1.0)), valence = 1),
  Au = list(name = "Gold", symbol = "Au", atomic_number = 79, isotopes = list("197" = list(196.96655200000001, 1.0)), valence = 1),
  B = list(name = "Boron", symbol = "B", atomic_number = 5, isotopes = list("10" = list(10.012937000000001, 0.19900000000000001), "11" = list(11.0093055, 0.80100000000000005)), valence = 3),
  Ba = list(name = "Barium", symbol = "Ba", atomic_number = 56, isotopes = list("130" = list(129.90630999999999, 0.00106), "132" = list(131.905056, 0.00101), "134" = list(133.90450300000001, 0.024170000000000001), "135" = list(134.90568300000001, 0.065920000000000006), "136" = list(135.90457000000001, 0.078539999999999999), "137" = list(136.905821, 0.11232), "138" = list(137.90524099999999, 0.71697999999999995)), valence = 2),
  Be = list(name = "Beryllium", symbol = "Be", atomic_number = 4, isotopes = list("9" = list(9.0121821000000004, 1.0)), valence = 2),
  Bh = list(name = "Bohrium", symbol = "Bh", atomic_number = 107, isotopes = list("264" = list(264.12473, 1.0)), valence = 0),
  Bi = list(name = "Bismuth", symbol = "Bi", atomic_number = 83, isotopes = list("209" = list(208.98038299999999, 1.0)), valence = 5),
  Bk = list(name = "Berkelium", symbol = "Bk", atomic_number = 97, isotopes = list("249" = list(249.07498000000001, 0.0), "247" = list(247.07029900000001, 1.0)), valence = 3),
  Br = list(name = "Bromine", symbol = "Br", atomic_number = 35, isotopes = list("81" = list(80.916291000000001, 0.49309999999999998), "79" = list(78.918337600000001, 0.50690000000000002)), valence = 1),
  C = list(name = "Carbon", symbol = "C", atomic_number = 6, isotopes = list("12" = list(12.0, 0.98929999999999996), "13" = list(13.0033548378, 0.010699999999999999), "14" = list(14.003241987999999, 0.0)), valence = 4),
  Ca = list(name = "Calcium", symbol = "Ca", atomic_number = 20, isotopes = list("40" = list(39.962591199999999, 0.96940999999999999), "42" = list(41.958618299999998, 0.0064700000000000001), "43" = list(42.958766799999999, 0.0013500000000000001), "44" = list(43.9554811, 0.02086), "46" = list(45.953692799999999, 4.0000000000000003e-05), "48" = list(47.952534, 0.0018699999999999999)), valence = 2),
  Cd = list(name = "Cadmium", symbol = "Cd", atomic_number = 48, isotopes = list("106" = list(105.906458, 0.012500000000000001), "108" = list(107.904183, 0.0088999999999999999), "110" = list(109.903006, 0.1249), "111" = list(110.90418200000001, 0.128), "112" = list(111.9027572, 0.24129999999999999), "113" = list(112.9044009, 0.1222), "114" = list(113.90335810000001, 0.2873), "116" = list(115.90475499999999, 0.074899999999999994)), valence = 2),
  Ce = list(name = "Cerium", symbol = "Ce", atomic_number = 58, isotopes = list("136" = list(135.90714, 0.0018500000000000001), "138" = list(137.90598600000001, 0.0025100000000000001), "140" = list(139.90543400000001, 0.88449999999999995), "142" = list(141.90924000000001, 0.11114)), valence = 4),
  Cf = list(name = "Californium", symbol = "Cf", atomic_number = 98, isotopes = list("249" = list(249.07484700000001, 0.0), "250" = list(250.07640000000001, 0.0), "251" = list(251.07957999999999, 1.0), "252" = list(252.08161999999999, 0.0)), valence = 3),
  Cl = list(name = "Chlorine", symbol = "Cl", atomic_number = 17, isotopes = list("35" = list(34.96885271, 0.75780000000000003), "37" = list(36.9659026, 0.2422)), valence = 1),
  Cm = list(name = "Curium", symbol = "Cm", atomic_number = 96, isotopes = list("243" = list(243.0613822, 0.0), "244" = list(244.06274629999999, 0.0), "245" = list(245.06548559999999, 0.0), "246" = list(246.06721759999999, 0.0), "247" = list(247.070347, 1.0), "248" = list(248.07234199999999, 0.0)), valence = 3),
  Co = list(name = "Cobalt", symbol = "Co", atomic_number = 27, isotopes = list("59" = list(58.933200200000002, 1.0)), valence = 2),
  Cr = list(name = "Chromium", symbol = "Cr", atomic_number = 24, isotopes = list("50" = list(49.946049600000002, 0.043450000000000003), "52" = list(51.940511899999997, 0.83789000000000002), "53" = list(52.9406538, 0.095009999999999997), "54" = list(53.938884899999998, 0.023650000000000001)), valence = 3),
  Cs = list(name = "Caesium", symbol = "Cs", atomic_number = 55, isotopes = list("133" = list(132.90544700000001, 1.0)), valence = 1),
  Cu = list(name = "Copper", symbol = "Cu", atomic_number = 29, isotopes = list("65" = list(64.927793699999995, 0.30830000000000002), "63" = list(62.929601099999999, 0.69169999999999998)), valence = 1),
  Db = list(name = "Dubnium", symbol = "Db", atomic_number = 105, isotopes = list("262" = list(262.11415, 1.0)), valence = 0),
  Dy = list(name = "Dysprosium", symbol = "Dy", atomic_number = 66, isotopes = list("160" = list(159.925194, 0.023400000000000001), "161" = list(160.92693, 0.18909999999999999), "162" = list(161.926795, 0.25509999999999999), "163" = list(162.92872800000001, 0.249), "164" = list(163.929171, 0.28179999999999999), "156" = list(155.92427799999999, 0.00059999999999999995), "158" = list(157.92440500000001, 0.001)), valence = 3),
  Er = list(name = "Erbium", symbol = "Er", atomic_number = 68, isotopes = list("162" = list(161.928775, 0.0014), "164" = list(163.92919699999999, 0.0161), "166" = list(165.93029000000001, 0.33610000000000001), "167" = list(166.93204499999999, 0.2293), "168" = list(167.932368, 0.26779999999999998), "170" = list(169.93546000000001, 0.14929999999999999)), valence = 3),
  Es = list(name = "Einsteinium", symbol = "Es", atomic_number = 99, isotopes = list("252" = list(252.08296999999999, 1.0)), valence = 3),
  Eu = list(name = "Europium", symbol = "Eu", atomic_number = 63, isotopes = list("153" = list(152.92122599999999, 0.52190000000000003), "151" = list(150.91984600000001, 0.47810000000000002)), valence = 2),
  "F" = list(name = "Fluorine", symbol = "F", atomic_number = 9, isotopes = list("19" = list(18.998403199999998, 1.0)), valence = 1),
  Fe = list(name = "Iron", symbol = "Fe", atomic_number = 26, isotopes = list("56" = list(55.934942100000001, 0.91754000000000002), "57" = list(56.9353987, 0.021190000000000001), "58" = list(57.933280500000002, 0.00282), "54" = list(53.939614800000001, 0.058450000000000002)), valence = 2),
  Fm = list(name = "Fermium", symbol = "Fm", atomic_number = 100, isotopes = list("257" = list(257.095099, 1.0)), valence = 3),
  Fr = list(name = "Francium", symbol = "Fr", atomic_number = 87, isotopes = list("223" = list(223.0197307, 1.0)), valence = 1),
  Ga = list(name = "Gallium", symbol = "Ga", atomic_number = 31, isotopes = list("69" = list(68.925580999999994, 0.60107999999999995), "71" = list(70.924705000000003, 0.39892)), valence = 3),
  Gd = list(name = "Gadolinium", symbol = "Gd", atomic_number = 64, isotopes = list("160" = list(159.92705100000001, 0.21859999999999999), "152" = list(151.91978800000001, 0.002), "154" = list(153.920862, 0.0218), "155" = list(154.922619, 0.14799999999999999), "156" = list(155.92212000000001, 0.20469999999999999), "157" = list(156.923957, 0.1565), "158" = list(157.92410100000001, 0.24840000000000001)), valence = 3),
  Ge = list(name = "Germanium", symbol = "Ge", atomic_number = 32, isotopes = list("72" = list(71.922076200000006, 0.27539999999999998), "73" = list(72.923459399999999, 0.077299999999999994), "74" = list(73.9211782, 0.36280000000000001), "76" = list(75.921402700000002, 0.076100000000000001), "70" = list(69.924250400000005, 0.2084)), valence = 4),
  H = list(name = "Hydrogen", symbol = "H", atomic_number = 1, isotopes = list("1" = list(1.0078250321, 0.99988500000000002), "2" = list(2.0141017780000001, 0.000115), "3" = list(3.0160492675000001, 0.0)), valence = 1),
  He = list(name = "Helium", symbol = "He", atomic_number = 2, isotopes = list("3" = list(3.0160293096999999, 1.37e-06), "4" = list(4.0026032496999999, 0.99999863)), valence = 0),
  Hf = list(name = "Hafnium", symbol = "Hf", atomic_number = 72, isotopes = list("174" = list(173.94004000000001, 0.0016000000000000001), "176" = list(175.94140179999999, 0.052600000000000001), "177" = list(176.94322, 0.186), "178" = list(177.9436977, 0.27279999999999999), "179" = list(178.9458151, 0.13619999999999999), "180" = list(179.94654879999999, 0.3508)), valence = 4),
  Hg = list(name = "Mercury", symbol = "Hg", atomic_number = 80, isotopes = list("196" = list(195.96581499999999, 0.0015), "198" = list(197.96675200000001, 0.099699999999999997), "199" = list(198.96826200000001, 0.16869999999999999), "200" = list(199.968309, 0.23100000000000001), "201" = list(200.97028499999999, 0.1318), "202" = list(201.97062600000001, 0.29859999999999998), "204" = list(203.97347600000001, 0.068699999999999997)), valence = 2),
  Ho = list(name = "Holmium", symbol = "Ho", atomic_number = 67, isotopes = list("165" = list(164.930319, 1.0)), valence = 3),
  I = list(name = "Iodine", symbol = "I", atomic_number = 53, isotopes = list("127" = list(126.90446799999999, 1.0)), valence = 1),
  In = list(name = "Indium", symbol = "In", atomic_number = 49, isotopes = list("113" = list(112.904061, 0.042900000000000001), "115" = list(114.90387800000001, 0.95709999999999995)), valence = 3),
  Ir = list(name = "Iridium", symbol = "Ir", atomic_number = 77, isotopes = list("193" = list(192.96292399999999, 0.627), "191" = list(190.96059099999999, 0.373)), valence = 3),
  K = list(name = "Potassium", symbol = "K", atomic_number = 19, isotopes = list("40" = list(39.963998670000002, 0.000117), "41" = list(40.96182597, 0.067302000000000001), "39" = list(38.963706899999998, 0.93258099999999999)), valence = 1),
  Kr = list(name = "Krypton", symbol = "Kr", atomic_number = 36, isotopes = list("78" = list(77.920385999999993, 0.0035000000000000001), "80" = list(79.916377999999995, 0.022800000000000001), "82" = list(81.913484600000004, 0.1158), "83" = list(82.914135999999999, 0.1149), "84" = list(83.911507, 0.56999999999999995), "86" = list(85.910610300000002, 0.17299999999999999)), valence = 0),
  La = list(name = "Lanthanum", symbol = "La", atomic_number = 57, isotopes = list("138" = list(137.907107, 0.00089999999999999998), "139" = list(138.90634800000001, 0.99909999999999999)), valence = 3),
  Li = list(name = "Lithium", symbol = "Li", atomic_number = 3, isotopes = list("6" = list(6.0151222999999998, 0.075899999999999995), "7" = list(7.0160039999999997, 0.92410000000000003)), valence = 1),
  Lr = list(name = "Lawrencium", symbol = "Lr", atomic_number = 103, isotopes = list("262" = list(262.10969, 1.0)), valence = 3),
  Lu = list(name = "Lutetium", symbol = "Lu", atomic_number = 71, isotopes = list("176" = list(175.9426824, 0.025899999999999999), "175" = list(174.9407679, 0.97409999999999997)), valence = 3),
  Md = list(name = "Mendelevium", symbol = "Md", atomic_number = 101, isotopes = list("256" = list(256.09404999999998, 0.0), "258" = list(258.09842500000002, 1.0)), valence = 3),
  Mg = list(name = "Magnesium", symbol = "Mg", atomic_number = 12, isotopes = list("24" = list(23.985041899999999, 0.78990000000000005), "25" = list(24.985837020000002, 0.10000000000000001), "26" = list(25.982593040000001, 0.1101)), valence = 2),
  Mn = list(name = "Manganese", symbol = "Mn", atomic_number = 25, isotopes = list("55" = list(54.938049599999999, 1.0)), valence = 2),
  Mo = list(name = "Molybdenum", symbol = "Mo", atomic_number = 42, isotopes = list("96" = list(95.904678899999993, 0.1668), "97" = list(96.906020999999996, 0.095500000000000002), "98" = list(97.905407800000006, 0.24129999999999999), "100" = list(99.907477, 0.096299999999999997), "92" = list(91.906809999999993, 0.1484), "94" = list(93.905087600000002, 0.092499999999999999), "95" = list(94.905841499999994, 0.15920000000000001)), valence = 6),
  Mt = list(name = "Meitnerium", symbol = "Mt", atomic_number = 109, isotopes = list("268" = list(268.13882000000001, 1.0)), valence = 0),
  N = list(name = "Nitrogen", symbol = "N", atomic_number = 7, isotopes = list("14" = list(14.0030740052, 0.99631999999999998), "15" = list(15.000108898400001, 0.0036800000000000001)), valence = 3),
  Na = list(name = "Sodium", symbol = "Na", atomic_number = 11, isotopes = list("23" = list(22.989769670000001, 1.0)), valence = 1),
  Nb = list(name = "Niobium", symbol = "Nb", atomic_number = 41, isotopes = list("93" = list(92.906377500000005, 1.0)), valence = 5),
  Nd = list(name = "Neodymium", symbol = "Nd", atomic_number = 60, isotopes = list("142" = list(141.90771899999999, 0.27200000000000002), "143" = list(142.90980999999999, 0.122), "144" = list(143.91008299999999, 0.23799999999999999), "145" = list(144.91256899999999, 0.083000000000000004), "146" = list(145.91311200000001, 0.17199999999999999), "148" = list(147.916889, 0.057000000000000002), "150" = list(149.92088699999999, 0.056000000000000001)), valence = 3),
  Ne = list(name = "Neon", symbol = "Ne", atomic_number = 10, isotopes = list("20" = list(19.992440175900001, 0.90480000000000005), "21" = list(20.993846739999999, 0.0027000000000000001), "22" = list(21.991385510000001, 0.092499999999999999)), valence = 0),
  Ni = list(name = "Nickel", symbol = "Ni", atomic_number = 28, isotopes = list("64" = list(63.927969599999997, 0.0092560000000000003), "58" = list(57.935347899999996, 0.68076899999999996), "60" = list(59.930790600000002, 0.26223099999999999), "61" = list(60.9310604, 0.011398999999999999), "62" = list(61.928348800000002, 0.036345000000000002)), valence = 2),
  No = list(name = "Nobelium", symbol = "No", atomic_number = 102, isotopes = list("259" = list(259.10102000000001, 1.0)), valence = 2),
  Np = list(name = "Neptunium", symbol = "Np", atomic_number = 93, isotopes = list("237" = list(237.04816729999999, 1.0), "239" = list(239.05293140000001, 0.0)), valence = 3),
  O = list(name = "Oxygen", symbol = "O", atomic_number = 8, isotopes = list("16" = list(15.9949146221, 0.99756999999999996), "17" = list(16.999131500000001, 0.00038000000000000002), "18" = list(17.999160400000001, 0.0020500000000000002)), valence = 2),
  Os = list(name = "Osmium", symbol = "Os", atomic_number = 76, isotopes = list("192" = list(191.961479, 0.4078), "184" = list(183.95249100000001, 0.00020000000000000001), "186" = list(185.95383799999999, 0.015900000000000001), "187" = list(186.95574790000001, 0.019599999999999999), "188" = list(187.95583600000001, 0.13239999999999999), "189" = list(188.95814490000001, 0.1615), "190" = list(189.95844500000001, 0.2626)), valence = 3),
  P = list(name = "Phosphorus", symbol = "P", atomic_number = 15, isotopes = list("31" = list(30.973761509999999, 1.0)), valence = 3),
  Pa = list(name = "Protactinium", symbol = "Pa", atomic_number = 91, isotopes = list("231" = list(231.0358789, 1.0)), valence = 4),
  Pb = list(name = "Lead", symbol = "Pb", atomic_number = 82, isotopes = list("208" = list(207.97663600000001, 0.52400000000000002), "204" = list(203.973029, 0.014), "206" = list(205.97444899999999, 0.24099999999999999), "207" = list(206.97588099999999, 0.221)), valence = 4),
  Pd = list(name = "Palladium", symbol = "Pd", atomic_number = 46, isotopes = list("102" = list(101.905608, 0.010200000000000001), "104" = list(103.90403499999999, 0.1114), "105" = list(104.905084, 0.2233), "106" = list(105.90348299999999, 0.27329999999999999), "108" = list(107.90389399999999, 0.2646), "110" = list(109.905152, 0.1172)), valence = 2),
  Pm = list(name = "Promethium", symbol = "Pm", atomic_number = 61, isotopes = list("145" = list(144.912744, 1.0), "147" = list(146.91513399999999, 0.0)), valence = 3),
  Po = list(name = "Polonium", symbol = "Po", atomic_number = 84, isotopes = list("209" = list(208.982416, 1.0), "210" = list(209.982857, 0.0)), valence = 2),
  Pr = list(name = "Praseodymium", symbol = "Pr", atomic_number = 59, isotopes = list("141" = list(140.90764799999999, 1.0)), valence = 3),
  Pt = list(name = "Platinum", symbol = "Pt", atomic_number = 78, isotopes = list("192" = list(191.96103500000001, 0.0078200000000000006), "194" = list(193.96266399999999, 0.32967000000000002), "195" = list(194.96477400000001, 0.33832000000000001), "196" = list(195.964935, 0.25241999999999998), "198" = list(197.96787599999999, 0.071629999999999999), "190" = list(189.95993000000001, 0.00013999999999999999)), valence = 2),
  Pu = list(name = "Plutonium", symbol = "Pu", atomic_number = 94, isotopes = list("238" = list(238.04955340000001, 0.0), "239" = list(239.0521565, 0.0), "240" = list(240.0538075, 0.0), "241" = list(241.05684529999999, 0.0), "242" = list(242.05873679999999, 0.0), "244" = list(244.064198, 1.0)), valence = 3),
  Ra = list(name = "Radium", symbol = "Ra", atomic_number = 88, isotopes = list("224" = list(224.02020200000001, 0.0), "226" = list(226.02540260000001, 1.0), "228" = list(228.03106410000001, 0.0), "223" = list(223.018497, 0.0)), valence = 2),
  Rb = list(name = "Rubidium", symbol = "Rb", atomic_number = 37, isotopes = list("85" = list(84.911789299999995, 0.72170000000000001), "87" = list(86.909183499999997, 0.27829999999999999)), valence = 1),
  Re = list(name = "Rhenium", symbol = "Re", atomic_number = 75, isotopes = list("185" = list(184.95295569999999, 0.374), "187" = list(186.9557508, 0.626)), valence = 4),
  Rf = list(name = "Rutherfordium", symbol = "Rf", atomic_number = 104, isotopes = list("261" = list(261.10874999999999, 1.0)), valence = 0),
  Rh = list(name = "Rhodium", symbol = "Rh", atomic_number = 45, isotopes = list("103" = list(102.90550399999999, 1.0)), valence = 3),
  Rn = list(name = "Radon", symbol = "Rn", atomic_number = 86, isotopes = list("211" = list(210.99058500000001, 0.0), "220" = list(220.01138409999999, 0.0), "222" = list(222.01757050000001, 1.0)), valence = 0),
  Ru = list(name = "Ruthenium", symbol = "Ru", atomic_number = 44, isotopes = list("96" = list(95.907597999999993, 0.055399999999999998), "98" = list(97.905287000000001, 0.018700000000000001), "99" = list(98.9059393, 0.12759999999999999), "100" = list(99.904219699999999, 0.126), "101" = list(100.9055822, 0.1706), "102" = list(101.9043495, 0.3155), "104" = list(103.90543, 0.1862)), valence = 3),
  S = list(name = "Sulfur", symbol = "S", atomic_number = 16, isotopes = list("32" = list(31.972070689999999, 0.94930000000000003), "33" = list(32.971458499999997, 0.0076), "34" = list(33.967866829999998, 0.042900000000000001), "36" = list(35.967080879999997, 0.00020000000000000001)), valence = 2),
  Sb = list(name = "Antimony", symbol = "Sb", atomic_number = 51, isotopes = list("121" = list(120.903818, 0.57210000000000005), "123" = list(122.90421569999999, 0.4279)), valence = 5),
  Sc = list(name = "Scandium", symbol = "Sc", atomic_number = 21, isotopes = list("45" = list(44.955910199999998, 1.0)), valence = 3),
  Se = list(name = "Selenium", symbol = "Se", atomic_number = 34, isotopes = list("74" = list(73.922476599999996, 0.0088999999999999999), "76" = list(75.919214100000005, 0.093700000000000006), "77" = list(76.919914599999998, 0.076300000000000007), "78" = list(77.917309500000002, 0.23769999999999999), "80" = list(79.916521799999998, 0.49609999999999999), "82" = list(81.916700000000006, 0.087300000000000003)), valence = 2),
  Sg = list(name = "Seaborgium", symbol = "Sg", atomic_number = 106, isotopes = list("266" = list(266.12193000000002, 1.0)), valence = 0),
  Si = list(name = "Silicon", symbol = "Si", atomic_number = 14, isotopes = list("28" = list(27.976926532699999, 0.92229700000000003), "29" = list(28.976494720000002, 0.046831999999999999), "30" = list(29.973770219999999, 0.030872)), valence = 4),
  Sm = list(name = "Samarium", symbol = "Sm", atomic_number = 62, isotopes = list("144" = list(143.91199499999999, 0.030700000000000002), "147" = list(146.91489300000001, 0.14990000000000001), "148" = list(147.914818, 0.1124), "149" = list(148.91718, 0.13819999999999999), "150" = list(149.917271, 0.073800000000000004), "152" = list(151.91972799999999, 0.26750000000000002), "154" = list(153.92220499999999, 0.22750000000000001)), valence = 2),
  Sn = list(name = "Tin", symbol = "Sn", atomic_number = 50, isotopes = list("112" = list(111.904821, 0.0097000000000000003), "114" = list(113.902782, 0.0066), "115" = list(114.903346, 0.0033999999999999998), "116" = list(115.90174399999999, 0.1454), "117" = list(116.90295399999999, 0.076799999999999993), "118" = list(117.901606, 0.2422), "119" = list(118.90330899999999, 0.085900000000000004), "120" = list(119.9021966, 0.32579999999999998), "122" = list(121.9034401, 0.046300000000000001), "124" = list(123.9052746, 0.0579)), valence = 4),
  Sr = list(name = "Strontium", symbol = "Sr", atomic_number = 38, isotopes = list("88" = list(87.905614299999996, 0.82579999999999998), "84" = list(83.913425000000004, 0.0055999999999999999), "86" = list(85.909262400000003, 0.098599999999999993), "87" = list(86.908879299999995, 0.070000000000000007)), valence = 2),
  Ta = list(name = "Tantalum", symbol = "Ta", atomic_number = 73, isotopes = list("180" = list(179.94746599999999, 0.00012), "181" = list(180.94799599999999, 0.99987999999999999)), valence = 5),
  Tb = list(name = "Terbium", symbol = "Tb", atomic_number = 65, isotopes = list("159" = list(158.925343, 1.0)), valence = 3),
  Tc = list(name = "Technetium", symbol = "Tc", atomic_number = 43, isotopes = list("97" = list(96.906364999999994, 0.0), "98" = list(97.907216000000005, 1.0), "99" = list(98.906254599999997, 0.0)), valence = 4),
  Te = list(name = "Tellurium", symbol = "Te", atomic_number = 52, isotopes = list("128" = list(127.9044614, 0.31740000000000002), "130" = list(129.90622279999999, 0.34079999999999999), "120" = list(119.90402, 0.00089999999999999998), "122" = list(121.90304709999999, 0.025499999999999998), "123" = list(122.904273, 0.0088999999999999999), "124" = list(123.90281950000001, 0.047399999999999998), "125" = list(124.90442470000001, 0.070699999999999999), "126" = list(125.9033055, 0.18840000000000001)), valence = 2),
  Th = list(name = "Thorium", symbol = "Th", atomic_number = 90, isotopes = list("232" = list(232.0380504, 1.0), "230" = list(230.0331266, 2.3203809999999998)), valence = 4),
  Ti = list(name = "Titanium", symbol = "Ti", atomic_number = 22, isotopes = list("48" = list(47.9479471, 0.73719999999999997), "49" = list(48.947870799999997, 0.054100000000000002), "50" = list(49.944792100000001, 0.051799999999999999), "46" = list(45.9526295, 0.082500000000000004), "47" = list(46.951763800000002, 0.074399999999999994)), valence = 4),
  Tl = list(name = "Thallium", symbol = "Tl", atomic_number = 81, isotopes = list("203" = list(202.972329, 0.29524), "205" = list(204.974412, 0.70476000000000005)), valence = 3),
  Tm = list(name = "Thulium", symbol = "Tm", atomic_number = 69, isotopes = list("169" = list(168.934211, 1.0)), valence = 3),
  U = list(name = "Uranium", symbol = "U", atomic_number = 92, isotopes = list("233" = list(233.03962799999999, 2.3802891000000002), "234" = list(234.04094559999999, 5.5000000000000002e-05), "235" = list(235.0439231, 0.0071999999999999998), "236" = list(236.0455619, 0.0), "238" = list(238.05078259999999, 0.99274499999999999)), valence = 3),
  V = list(name = "Vanadium", symbol = "V", atomic_number = 23, isotopes = list("50" = list(49.947162800000001, 0.0025000000000000001), "51" = list(50.943963699999998, 0.99750000000000005)), valence = 5),
  W = list(name = "Tungsten", symbol = "W", atomic_number = 74, isotopes = list("184" = list(183.95093259999999, 0.30640000000000001), "186" = list(185.954362, 0.2843), "180" = list(179.94670600000001, 0.0011999999999999999), "182" = list(181.948206, 0.26500000000000001), "183" = list(182.95022449999999, 0.1431)), valence = 6),
  Xe = list(name = "Xenon", symbol = "Xe", atomic_number = 54, isotopes = list("128" = list(127.90353039999999, 0.019199999999999998), "129" = list(128.90477949999999, 0.26440000000000002), "130" = list(129.90350789999999, 0.040800000000000003), "131" = list(130.9050819, 0.21179999999999999), "132" = list(131.9041545, 0.26889999999999997), "134" = list(133.9053945, 0.10440000000000001), "136" = list(135.90722, 0.088700000000000001), "124" = list(123.9058958, 0.00089999999999999998), "126" = list(125.904269, 0.00089999999999999998)), valence = 0),
  Y = list(name = "Yttrium", symbol = "Y", atomic_number = 39, isotopes = list("89" = list(88.905847899999998, 1.0)), valence = 3),
  Yb = list(name = "Ytterbium", symbol = "Yb", atomic_number = 70, isotopes = list("168" = list(167.93389400000001, 0.0012999999999999999), "170" = list(169.93475900000001, 0.0304), "171" = list(170.93632199999999, 0.14280000000000001), "172" = list(171.93637770000001, 0.21829999999999999), "173" = list(172.93820679999999, 0.1613), "174" = list(173.9388581, 0.31830000000000003), "176" = list(175.94256799999999, 0.12759999999999999)), valence = 2),
  Zn = list(name = "Zinc", symbol = "Zn", atomic_number = 30, isotopes = list("64" = list(63.929146600000003, 0.48630000000000001), "66" = list(65.926036800000006, 0.27900000000000003), "67" = list(66.927130899999995, 0.041000000000000002), "68" = list(67.924847600000007, 0.1875), "70" = list(69.925325000000001, 0.0061999999999999998)), valence = 2),
  Zr = list(name = "Zirconium", symbol = "Zr", atomic_number = 40, isotopes = list("96" = list(95.908276000000001, 0.028000000000000001), "90" = list(89.904703699999999, 0.51449999999999996), "91" = list(90.905645000000007, 0.11219999999999999), "92" = list(91.905040099999994, 0.17150000000000001), "94" = list(93.906315800000002, 0.17380000000000001)), valence = 4)
)


isotopes_table <- imap(elements_table, function(el, sym) {
  el$oxides <- oxide_list[[sym]] %||% character(0)
  el
})
