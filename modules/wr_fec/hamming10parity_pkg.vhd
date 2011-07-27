LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_unsigned.all;

PACKAGE hamm_package_496bit IS
	SUBTYPE parity_ham_496bit IS std_logic_vector(9 DOWNTO 0);
	SUBTYPE data_ham_496bit IS std_logic_vector(495 DOWNTO 0);
	SUBTYPE coded_ham_496bit IS std_logic_vector(505 DOWNTO 0);

	FUNCTION hamming_encoder_496bit(data_in:data_ham_496bit) RETURN parity_ham_496bit;
	PROCEDURE hamming_decoder_496bit(data_parity_in:coded_ham_496bit;
		SIGNAL error_out : OUT std_logic_vector(1 DOWNTO 0);
		SIGNAL decoded : OUT data_ham_496bit);
END hamm_package_496bit;

PACKAGE BODY hamm_package_496bit IS

---------------------
-- HAMMING ENCODER --
---------------------
FUNCTION hamming_encoder_496bit(data_in:data_ham_496bit) RETURN parity_ham_496bit  IS
	VARIABLE parity: parity_ham_496bit;
BEGIN

	parity(9)	:=	data_in(247) XOR data_in(248) XOR data_in(249) XOR data_in(250) XOR data_in(251) XOR 
					data_in(252) XOR data_in(253) XOR data_in(254) XOR data_in(255) XOR data_in(256) XOR 
					data_in(257) XOR data_in(258) XOR data_in(259) XOR data_in(260) XOR data_in(261) XOR 
					data_in(262) XOR data_in(263) XOR data_in(264) XOR data_in(265) XOR data_in(266) XOR 
					data_in(267) XOR data_in(268) XOR data_in(269) XOR data_in(270) XOR data_in(271) XOR 
					data_in(272) XOR data_in(273) XOR data_in(274) XOR data_in(275) XOR data_in(276) XOR 
					data_in(277) XOR data_in(278) XOR data_in(279) XOR data_in(280) XOR data_in(281) XOR 
					data_in(282) XOR data_in(283) XOR data_in(284) XOR data_in(285) XOR data_in(286) XOR 
					data_in(287) XOR data_in(288) XOR data_in(289) XOR data_in(290) XOR data_in(291) XOR 
					data_in(292) XOR data_in(293) XOR data_in(294) XOR data_in(295) XOR data_in(296) XOR 
					data_in(297) XOR data_in(298) XOR data_in(299) XOR data_in(300) XOR data_in(301) XOR 
					data_in(302) XOR data_in(303) XOR data_in(304) XOR data_in(305) XOR data_in(306) XOR 
					data_in(307) XOR data_in(308) XOR data_in(309) XOR data_in(310) XOR data_in(311) XOR 
					data_in(312) XOR data_in(313) XOR data_in(314) XOR data_in(315) XOR data_in(316) XOR 
					data_in(317) XOR data_in(318) XOR data_in(319) XOR data_in(320) XOR data_in(321) XOR 
					data_in(322) XOR data_in(323) XOR data_in(324) XOR data_in(325) XOR data_in(326) XOR 
					data_in(327) XOR data_in(328) XOR data_in(329) XOR data_in(330) XOR data_in(331) XOR 
					data_in(332) XOR data_in(333) XOR data_in(334) XOR data_in(335) XOR data_in(336) XOR 
					data_in(337) XOR data_in(338) XOR data_in(339) XOR data_in(340) XOR data_in(341) XOR 
					data_in(342) XOR data_in(343) XOR data_in(344) XOR data_in(345) XOR data_in(346) XOR 
					data_in(347) XOR data_in(348) XOR data_in(349) XOR data_in(350) XOR data_in(351) XOR 
					data_in(352) XOR data_in(353) XOR data_in(354) XOR data_in(355) XOR data_in(356) XOR 
					data_in(357) XOR data_in(358) XOR data_in(359) XOR data_in(360) XOR data_in(361) XOR 
					data_in(362) XOR data_in(363) XOR data_in(364) XOR data_in(365) XOR data_in(366) XOR 
					data_in(367) XOR data_in(368) XOR data_in(369) XOR data_in(370) XOR data_in(371) XOR 
					data_in(372) XOR data_in(373) XOR data_in(374) XOR data_in(375) XOR data_in(376) XOR 
					data_in(377) XOR data_in(378) XOR data_in(379) XOR data_in(380) XOR data_in(381) XOR 
					data_in(382) XOR data_in(383) XOR data_in(384) XOR data_in(385) XOR data_in(386) XOR 
					data_in(387) XOR data_in(388) XOR data_in(389) XOR data_in(390) XOR data_in(391) XOR 
					data_in(392) XOR data_in(393) XOR data_in(394) XOR data_in(395) XOR data_in(396) XOR 
					data_in(397) XOR data_in(398) XOR data_in(399) XOR data_in(400) XOR data_in(401) XOR 
					data_in(402) XOR data_in(403) XOR data_in(404) XOR data_in(405) XOR data_in(406) XOR 
					data_in(407) XOR data_in(408) XOR data_in(409) XOR data_in(410) XOR data_in(411) XOR 
					data_in(412) XOR data_in(413) XOR data_in(414) XOR data_in(415) XOR data_in(416) XOR 
					data_in(417) XOR data_in(418) XOR data_in(419) XOR data_in(420) XOR data_in(421) XOR 
					data_in(422) XOR data_in(423) XOR data_in(424) XOR data_in(425) XOR data_in(426) XOR 
					data_in(427) XOR data_in(428) XOR data_in(429) XOR data_in(430) XOR data_in(431) XOR 
					data_in(432) XOR data_in(433) XOR data_in(434) XOR data_in(435) XOR data_in(436) XOR 
					data_in(437) XOR data_in(438) XOR data_in(439) XOR data_in(440) XOR data_in(441) XOR 
					data_in(442) XOR data_in(443) XOR data_in(444) XOR data_in(445) XOR data_in(446) XOR 
					data_in(447) XOR data_in(448) XOR data_in(449) XOR data_in(450) XOR data_in(451) XOR 
					data_in(452) XOR data_in(453) XOR data_in(454) XOR data_in(455) XOR data_in(456) XOR 
					data_in(457) XOR data_in(458) XOR data_in(459) XOR data_in(460) XOR data_in(461) XOR 
					data_in(462) XOR data_in(463) XOR data_in(464) XOR data_in(465) XOR data_in(466) XOR 
					data_in(467) XOR data_in(468) XOR data_in(469) XOR data_in(470) XOR data_in(471) XOR 
					data_in(472) XOR data_in(473) XOR data_in(474) XOR data_in(475) XOR data_in(476) XOR 
					data_in(477) XOR data_in(478) XOR data_in(479) XOR data_in(480) XOR data_in(481) XOR 
					data_in(482) XOR data_in(483) XOR data_in(484) XOR data_in(485) XOR data_in(486) XOR 
					data_in(487) XOR data_in(488) XOR data_in(489) XOR data_in(490) XOR data_in(491) XOR 
					data_in(492) XOR data_in(493) XOR data_in(494) XOR data_in(495);
   
	parity(8)	:=	data_in(120) XOR data_in(121) XOR data_in(122) XOR data_in(123) XOR data_in(124) XOR 
					data_in(125) XOR data_in(126) XOR data_in(127) XOR data_in(128) XOR data_in(129) XOR 
					data_in(130) XOR data_in(131) XOR data_in(132) XOR data_in(133) XOR data_in(134) XOR 
					data_in(135) XOR data_in(136) XOR data_in(137) XOR data_in(138) XOR data_in(139) XOR 
					data_in(140) XOR data_in(141) XOR data_in(142) XOR data_in(143) XOR data_in(144) XOR 
					data_in(145) XOR data_in(146) XOR data_in(147) XOR data_in(148) XOR data_in(149) XOR 
					data_in(150) XOR data_in(151) XOR data_in(152) XOR data_in(153) XOR data_in(154) XOR 
					data_in(155) XOR data_in(156) XOR data_in(157) XOR data_in(158) XOR data_in(159) XOR 
					data_in(160) XOR data_in(161) XOR data_in(162) XOR data_in(163) XOR data_in(164) XOR 
					data_in(165) XOR data_in(166) XOR data_in(167) XOR data_in(168) XOR data_in(169) XOR 
					data_in(170) XOR data_in(171) XOR data_in(172) XOR data_in(173) XOR data_in(174) XOR 
					data_in(175) XOR data_in(176) XOR data_in(177) XOR data_in(178) XOR data_in(179) XOR 
					data_in(180) XOR data_in(181) XOR data_in(182) XOR data_in(183) XOR data_in(184) XOR 
					data_in(185) XOR data_in(186) XOR data_in(187) XOR data_in(188) XOR data_in(189) XOR 
					data_in(190) XOR data_in(191) XOR data_in(192) XOR data_in(193) XOR data_in(194) XOR 
					data_in(195) XOR data_in(196) XOR data_in(197) XOR data_in(198) XOR data_in(199) XOR 
					data_in(200) XOR data_in(201) XOR data_in(202) XOR data_in(203) XOR data_in(204) XOR 
					data_in(205) XOR data_in(206) XOR data_in(207) XOR data_in(208) XOR data_in(209) XOR 
					data_in(210) XOR data_in(211) XOR data_in(212) XOR data_in(213) XOR data_in(214) XOR 
					data_in(215) XOR data_in(216) XOR data_in(217) XOR data_in(218) XOR data_in(219) XOR 
					data_in(220) XOR data_in(221) XOR data_in(222) XOR data_in(223) XOR data_in(224) XOR 
					data_in(225) XOR data_in(226) XOR data_in(227) XOR data_in(228) XOR data_in(229) XOR 
					data_in(230) XOR data_in(231) XOR data_in(232) XOR data_in(233) XOR data_in(234) XOR 
					data_in(235) XOR data_in(236) XOR data_in(237) XOR data_in(238) XOR data_in(239) XOR 
					data_in(240) XOR data_in(241) XOR data_in(242) XOR data_in(243) XOR data_in(244) XOR 
					data_in(245) XOR data_in(246) XOR data_in(374) XOR data_in(375) XOR data_in(376) XOR 
					data_in(377) XOR data_in(378) XOR data_in(379) XOR data_in(380) XOR data_in(381) XOR 
					data_in(382) XOR data_in(383) XOR data_in(384) XOR data_in(385) XOR data_in(386) XOR 
					data_in(387) XOR data_in(388) XOR data_in(389) XOR data_in(390) XOR data_in(391) XOR 
					data_in(392) XOR data_in(393) XOR data_in(394) XOR data_in(395) XOR data_in(396) XOR 
					data_in(397) XOR data_in(398) XOR data_in(399) XOR data_in(400) XOR data_in(401) XOR 
					data_in(402) XOR data_in(403) XOR data_in(404) XOR data_in(405) XOR data_in(406) XOR 
					data_in(407) XOR data_in(408) XOR data_in(409) XOR data_in(410) XOR data_in(411) XOR 
					data_in(412) XOR data_in(413) XOR data_in(414) XOR data_in(415) XOR data_in(416) XOR 
					data_in(417) XOR data_in(418) XOR data_in(419) XOR data_in(420) XOR data_in(421) XOR 
					data_in(422) XOR data_in(423) XOR data_in(424) XOR data_in(425) XOR data_in(426) XOR 
					data_in(427) XOR data_in(428) XOR data_in(429) XOR data_in(430) XOR data_in(431) XOR 
					data_in(432) XOR data_in(433) XOR data_in(434) XOR data_in(435) XOR data_in(436) XOR 
					data_in(437) XOR data_in(438) XOR data_in(439) XOR data_in(440) XOR data_in(441) XOR 
					data_in(442) XOR data_in(443) XOR data_in(444) XOR data_in(445) XOR data_in(446) XOR 
					data_in(447) XOR data_in(448) XOR data_in(449) XOR data_in(450) XOR data_in(451) XOR 
					data_in(452) XOR data_in(453) XOR data_in(454) XOR data_in(455) XOR data_in(456) XOR 
					data_in(457) XOR data_in(458) XOR data_in(459) XOR data_in(460) XOR data_in(461) XOR 
					data_in(462) XOR data_in(463) XOR data_in(464) XOR data_in(465) XOR data_in(466) XOR 
					data_in(467) XOR data_in(468) XOR data_in(469) XOR data_in(470) XOR data_in(471) XOR 
					data_in(472) XOR data_in(473) XOR data_in(474) XOR data_in(475) XOR data_in(476) XOR 
					data_in(477) XOR data_in(478) XOR data_in(479) XOR data_in(480) XOR data_in(481) XOR 
					data_in(482) XOR data_in(483) XOR data_in(484) XOR data_in(485) XOR data_in(486) XOR 
					data_in(487) XOR data_in(488) XOR data_in(489) XOR data_in(490) XOR data_in(491) XOR 
					data_in(492) XOR data_in(493) XOR data_in(494) XOR data_in(495);
   
	parity(7)	:=	data_in(57) XOR data_in(58) XOR data_in(59) XOR data_in(60) XOR data_in(61) XOR 
					data_in(62) XOR data_in(63) XOR data_in(64) XOR data_in(65) XOR data_in(66) XOR 
					data_in(67) XOR data_in(68) XOR data_in(69) XOR data_in(70) XOR data_in(71) XOR 
					data_in(72) XOR data_in(73) XOR data_in(74) XOR data_in(75) XOR data_in(76) XOR 
					data_in(77) XOR data_in(78) XOR data_in(79) XOR data_in(80) XOR data_in(81) XOR 
					data_in(82) XOR data_in(83) XOR data_in(84) XOR data_in(85) XOR data_in(86) XOR 
					data_in(87) XOR data_in(88) XOR data_in(89) XOR data_in(90) XOR data_in(91) XOR 
					data_in(92) XOR data_in(93) XOR data_in(94) XOR data_in(95) XOR data_in(96) XOR 
					data_in(97) XOR data_in(98) XOR data_in(99) XOR data_in(100) XOR data_in(101) XOR 
					data_in(102) XOR data_in(103) XOR data_in(104) XOR data_in(105) XOR data_in(106) XOR 
					data_in(107) XOR data_in(108) XOR data_in(109) XOR data_in(110) XOR data_in(111) XOR 
					data_in(112) XOR data_in(113) XOR data_in(114) XOR data_in(115) XOR data_in(116) XOR 
					data_in(117) XOR data_in(118) XOR data_in(119) XOR data_in(183) XOR data_in(184) XOR 
					data_in(185) XOR data_in(186) XOR data_in(187) XOR data_in(188) XOR data_in(189) XOR 
					data_in(190) XOR data_in(191) XOR data_in(192) XOR data_in(193) XOR data_in(194) XOR 
					data_in(195) XOR data_in(196) XOR data_in(197) XOR data_in(198) XOR data_in(199) XOR 
					data_in(200) XOR data_in(201) XOR data_in(202) XOR data_in(203) XOR data_in(204) XOR 
					data_in(205) XOR data_in(206) XOR data_in(207) XOR data_in(208) XOR data_in(209) XOR 
					data_in(210) XOR data_in(211) XOR data_in(212) XOR data_in(213) XOR data_in(214) XOR 
					data_in(215) XOR data_in(216) XOR data_in(217) XOR data_in(218) XOR data_in(219) XOR 
					data_in(220) XOR data_in(221) XOR data_in(222) XOR data_in(223) XOR data_in(224) XOR 
					data_in(225) XOR data_in(226) XOR data_in(227) XOR data_in(228) XOR data_in(229) XOR 
					data_in(230) XOR data_in(231) XOR data_in(232) XOR data_in(233) XOR data_in(234) XOR 
					data_in(235) XOR data_in(236) XOR data_in(237) XOR data_in(238) XOR data_in(239) XOR 
					data_in(240) XOR data_in(241) XOR data_in(242) XOR data_in(243) XOR data_in(244) XOR 
					data_in(245) XOR data_in(246) XOR data_in(310) XOR data_in(311) XOR data_in(312) XOR 
					data_in(313) XOR data_in(314) XOR data_in(315) XOR data_in(316) XOR data_in(317) XOR 
					data_in(318) XOR data_in(319) XOR data_in(320) XOR data_in(321) XOR data_in(322) XOR 
					data_in(323) XOR data_in(324) XOR data_in(325) XOR data_in(326) XOR data_in(327) XOR 
					data_in(328) XOR data_in(329) XOR data_in(330) XOR data_in(331) XOR data_in(332) XOR 
					data_in(333) XOR data_in(334) XOR data_in(335) XOR data_in(336) XOR data_in(337) XOR 
					data_in(338) XOR data_in(339) XOR data_in(340) XOR data_in(341) XOR data_in(342) XOR 
					data_in(343) XOR data_in(344) XOR data_in(345) XOR data_in(346) XOR data_in(347) XOR 
					data_in(348) XOR data_in(349) XOR data_in(350) XOR data_in(351) XOR data_in(352) XOR 
					data_in(353) XOR data_in(354) XOR data_in(355) XOR data_in(356) XOR data_in(357) XOR 
					data_in(358) XOR data_in(359) XOR data_in(360) XOR data_in(361) XOR data_in(362) XOR 
					data_in(363) XOR data_in(364) XOR data_in(365) XOR data_in(366) XOR data_in(367) XOR 
					data_in(368) XOR data_in(369) XOR data_in(370) XOR data_in(371) XOR data_in(372) XOR 
					data_in(373) XOR data_in(438) XOR data_in(439) XOR data_in(440) XOR data_in(441) XOR 
					data_in(442) XOR data_in(443) XOR data_in(444) XOR data_in(445) XOR data_in(446) XOR 
					data_in(447) XOR data_in(448) XOR data_in(449) XOR data_in(450) XOR data_in(451) XOR 
					data_in(452) XOR data_in(453) XOR data_in(454) XOR data_in(455) XOR data_in(456) XOR 
					data_in(457) XOR data_in(458) XOR data_in(459) XOR data_in(460) XOR data_in(461) XOR 
					data_in(462) XOR data_in(463) XOR data_in(464) XOR data_in(465) XOR data_in(466) XOR 
					data_in(467) XOR data_in(468) XOR data_in(469) XOR data_in(470) XOR data_in(471) XOR 
					data_in(472) XOR data_in(473) XOR data_in(474) XOR data_in(475) XOR data_in(476) XOR 
					data_in(477) XOR data_in(478) XOR data_in(479) XOR data_in(480) XOR data_in(481) XOR 
					data_in(482) XOR data_in(483) XOR data_in(484) XOR data_in(485) XOR data_in(486) XOR 
					data_in(487) XOR data_in(488) XOR data_in(489) XOR data_in(490) XOR data_in(491) XOR 
					data_in(492) XOR data_in(493) XOR data_in(494) XOR data_in(495);
   
	parity(6)	:=	data_in(26) XOR data_in(27) XOR data_in(28) XOR data_in(29) XOR data_in(30) XOR 
					data_in(31) XOR data_in(32) XOR data_in(33) XOR data_in(34) XOR data_in(35) XOR 
					data_in(36) XOR data_in(37) XOR data_in(38) XOR data_in(39) XOR data_in(40) XOR 
					data_in(41) XOR data_in(42) XOR data_in(43) XOR data_in(44) XOR data_in(45) XOR 
					data_in(46) XOR data_in(47) XOR data_in(48) XOR data_in(49) XOR data_in(50) XOR 
					data_in(51) XOR data_in(52) XOR data_in(53) XOR data_in(54) XOR data_in(55) XOR 
					data_in(56) XOR data_in(88) XOR data_in(89) XOR data_in(90) XOR data_in(91) XOR 
					data_in(92) XOR data_in(93) XOR data_in(94) XOR data_in(95) XOR data_in(96) XOR 
					data_in(97) XOR data_in(98) XOR data_in(99) XOR data_in(100) XOR data_in(101) XOR 
					data_in(102) XOR data_in(103) XOR data_in(104) XOR data_in(105) XOR data_in(106) XOR 
					data_in(107) XOR data_in(108) XOR data_in(109) XOR data_in(110) XOR data_in(111) XOR 
					data_in(112) XOR data_in(113) XOR data_in(114) XOR data_in(115) XOR data_in(116) XOR 
					data_in(117) XOR data_in(118) XOR data_in(119) XOR data_in(151) XOR data_in(152) XOR 
					data_in(153) XOR data_in(154) XOR data_in(155) XOR data_in(156) XOR data_in(157) XOR 
					data_in(158) XOR data_in(159) XOR data_in(160) XOR data_in(161) XOR data_in(162) XOR 
					data_in(163) XOR data_in(164) XOR data_in(165) XOR data_in(166) XOR data_in(167) XOR 
					data_in(168) XOR data_in(169) XOR data_in(170) XOR data_in(171) XOR data_in(172) XOR 
					data_in(173) XOR data_in(174) XOR data_in(175) XOR data_in(176) XOR data_in(177) XOR 
					data_in(178) XOR data_in(179) XOR data_in(180) XOR data_in(181) XOR data_in(182) XOR 
					data_in(215) XOR data_in(216) XOR data_in(217) XOR data_in(218) XOR data_in(219) XOR 
					data_in(220) XOR data_in(221) XOR data_in(222) XOR data_in(223) XOR data_in(224) XOR 
					data_in(225) XOR data_in(226) XOR data_in(227) XOR data_in(228) XOR data_in(229) XOR 
					data_in(230) XOR data_in(231) XOR data_in(232) XOR data_in(233) XOR data_in(234) XOR 
					data_in(235) XOR data_in(236) XOR data_in(237) XOR data_in(238) XOR data_in(239) XOR 
					data_in(240) XOR data_in(241) XOR data_in(242) XOR data_in(243) XOR data_in(244) XOR 
					data_in(245) XOR data_in(246) XOR data_in(278) XOR data_in(279) XOR data_in(280) XOR 
					data_in(281) XOR data_in(282) XOR data_in(283) XOR data_in(284) XOR data_in(285) XOR 
					data_in(286) XOR data_in(287) XOR data_in(288) XOR data_in(289) XOR data_in(290) XOR 
					data_in(291) XOR data_in(292) XOR data_in(293) XOR data_in(294) XOR data_in(295) XOR 
					data_in(296) XOR data_in(297) XOR data_in(298) XOR data_in(299) XOR data_in(300) XOR 
					data_in(301) XOR data_in(302) XOR data_in(303) XOR data_in(304) XOR data_in(305) XOR 
					data_in(306) XOR data_in(307) XOR data_in(308) XOR data_in(309) XOR data_in(342) XOR 
					data_in(343) XOR data_in(344) XOR data_in(345) XOR data_in(346) XOR data_in(347) XOR 
					data_in(348) XOR data_in(349) XOR data_in(350) XOR data_in(351) XOR data_in(352) XOR 
					data_in(353) XOR data_in(354) XOR data_in(355) XOR data_in(356) XOR data_in(357) XOR 
					data_in(358) XOR data_in(359) XOR data_in(360) XOR data_in(361) XOR data_in(362) XOR 
					data_in(363) XOR data_in(364) XOR data_in(365) XOR data_in(366) XOR data_in(367) XOR 
					data_in(368) XOR data_in(369) XOR data_in(370) XOR data_in(371) XOR data_in(372) XOR 
					data_in(373) XOR data_in(406) XOR data_in(407) XOR data_in(408) XOR data_in(409) XOR 
					data_in(410) XOR data_in(411) XOR data_in(412) XOR data_in(413) XOR data_in(414) XOR 
					data_in(415) XOR data_in(416) XOR data_in(417) XOR data_in(418) XOR data_in(419) XOR 
					data_in(420) XOR data_in(421) XOR data_in(422) XOR data_in(423) XOR data_in(424) XOR 
					data_in(425) XOR data_in(426) XOR data_in(427) XOR data_in(428) XOR data_in(429) XOR 
					data_in(430) XOR data_in(431) XOR data_in(432) XOR data_in(433) XOR data_in(434) XOR 
					data_in(435) XOR data_in(436) XOR data_in(437) XOR data_in(470) XOR data_in(471) XOR 
					data_in(472) XOR data_in(473) XOR data_in(474) XOR data_in(475) XOR data_in(476) XOR 
					data_in(477) XOR data_in(478) XOR data_in(479) XOR data_in(480) XOR data_in(481) XOR 
					data_in(482) XOR data_in(483) XOR data_in(484) XOR data_in(485) XOR data_in(486) XOR 
					data_in(487) XOR data_in(488) XOR data_in(489) XOR data_in(490) XOR data_in(491) XOR 
					data_in(492) XOR data_in(493) XOR data_in(494) XOR data_in(495);
   
	parity(5)	:=	data_in(11) XOR data_in(12) XOR data_in(13) XOR data_in(14) XOR data_in(15) XOR 
					data_in(16) XOR data_in(17) XOR data_in(18) XOR data_in(19) XOR data_in(20) XOR 
					data_in(21) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR data_in(25) XOR 
					data_in(41) XOR data_in(42) XOR data_in(43) XOR data_in(44) XOR data_in(45) XOR 
					data_in(46) XOR data_in(47) XOR data_in(48) XOR data_in(49) XOR data_in(50) XOR 
					data_in(51) XOR data_in(52) XOR data_in(53) XOR data_in(54) XOR data_in(55) XOR 
					data_in(56) XOR data_in(72) XOR data_in(73) XOR data_in(74) XOR data_in(75) XOR 
					data_in(76) XOR data_in(77) XOR data_in(78) XOR data_in(79) XOR data_in(80) XOR 
					data_in(81) XOR data_in(82) XOR data_in(83) XOR data_in(84) XOR data_in(85) XOR 
					data_in(86) XOR data_in(87) XOR data_in(104) XOR data_in(105) XOR data_in(106) XOR 
					data_in(107) XOR data_in(108) XOR data_in(109) XOR data_in(110) XOR data_in(111) XOR 
					data_in(112) XOR data_in(113) XOR data_in(114) XOR data_in(115) XOR data_in(116) XOR 
					data_in(117) XOR data_in(118) XOR data_in(119) XOR data_in(135) XOR data_in(136) XOR 
					data_in(137) XOR data_in(138) XOR data_in(139) XOR data_in(140) XOR data_in(141) XOR 
					data_in(142) XOR data_in(143) XOR data_in(144) XOR data_in(145) XOR data_in(146) XOR 
					data_in(147) XOR data_in(148) XOR data_in(149) XOR data_in(150) XOR data_in(167) XOR 
					data_in(168) XOR data_in(169) XOR data_in(170) XOR data_in(171) XOR data_in(172) XOR 
					data_in(173) XOR data_in(174) XOR data_in(175) XOR data_in(176) XOR data_in(177) XOR 
					data_in(178) XOR data_in(179) XOR data_in(180) XOR data_in(181) XOR data_in(182) XOR 
					data_in(199) XOR data_in(200) XOR data_in(201) XOR data_in(202) XOR data_in(203) XOR 
					data_in(204) XOR data_in(205) XOR data_in(206) XOR data_in(207) XOR data_in(208) XOR 
					data_in(209) XOR data_in(210) XOR data_in(211) XOR data_in(212) XOR data_in(213) XOR 
					data_in(214) XOR data_in(231) XOR data_in(232) XOR data_in(233) XOR data_in(234) XOR 
					data_in(235) XOR data_in(236) XOR data_in(237) XOR data_in(238) XOR data_in(239) XOR 
					data_in(240) XOR data_in(241) XOR data_in(242) XOR data_in(243) XOR data_in(244) XOR 
					data_in(245) XOR data_in(246) XOR data_in(262) XOR data_in(263) XOR data_in(264) XOR 
					data_in(265) XOR data_in(266) XOR data_in(267) XOR data_in(268) XOR data_in(269) XOR 
					data_in(270) XOR data_in(271) XOR data_in(272) XOR data_in(273) XOR data_in(274) XOR 
					data_in(275) XOR data_in(276) XOR data_in(277) XOR data_in(294) XOR data_in(295) XOR 
					data_in(296) XOR data_in(297) XOR data_in(298) XOR data_in(299) XOR data_in(300) XOR 
					data_in(301) XOR data_in(302) XOR data_in(303) XOR data_in(304) XOR data_in(305) XOR 
					data_in(306) XOR data_in(307) XOR data_in(308) XOR data_in(309) XOR data_in(326) XOR 
					data_in(327) XOR data_in(328) XOR data_in(329) XOR data_in(330) XOR data_in(331) XOR 
					data_in(332) XOR data_in(333) XOR data_in(334) XOR data_in(335) XOR data_in(336) XOR 
					data_in(337) XOR data_in(338) XOR data_in(339) XOR data_in(340) XOR data_in(341) XOR 
					data_in(358) XOR data_in(359) XOR data_in(360) XOR data_in(361) XOR data_in(362) XOR 
					data_in(363) XOR data_in(364) XOR data_in(365) XOR data_in(366) XOR data_in(367) XOR 
					data_in(368) XOR data_in(369) XOR data_in(370) XOR data_in(371) XOR data_in(372) XOR 
					data_in(373) XOR data_in(390) XOR data_in(391) XOR data_in(392) XOR data_in(393) XOR 
					data_in(394) XOR data_in(395) XOR data_in(396) XOR data_in(397) XOR data_in(398) XOR 
					data_in(399) XOR data_in(400) XOR data_in(401) XOR data_in(402) XOR data_in(403) XOR 
					data_in(404) XOR data_in(405) XOR data_in(422) XOR data_in(423) XOR data_in(424) XOR 
					data_in(425) XOR data_in(426) XOR data_in(427) XOR data_in(428) XOR data_in(429) XOR 
					data_in(430) XOR data_in(431) XOR data_in(432) XOR data_in(433) XOR data_in(434) XOR 
					data_in(435) XOR data_in(436) XOR data_in(437) XOR data_in(454) XOR data_in(455) XOR 
					data_in(456) XOR data_in(457) XOR data_in(458) XOR data_in(459) XOR data_in(460) XOR 
					data_in(461) XOR data_in(462) XOR data_in(463) XOR data_in(464) XOR data_in(465) XOR 
					data_in(466) XOR data_in(467) XOR data_in(468) XOR data_in(469) XOR data_in(486) XOR 
					data_in(487) XOR data_in(488) XOR data_in(489) XOR data_in(490) XOR data_in(491) XOR 
					data_in(492) XOR data_in(493) XOR data_in(494) XOR data_in(495);
   
	parity(4)	:=	data_in(4) XOR data_in(5) XOR data_in(6) XOR data_in(7) XOR data_in(8) XOR 
					data_in(9) XOR data_in(10) XOR data_in(18) XOR data_in(19) XOR data_in(20) XOR 
					data_in(21) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR data_in(25) XOR 
					data_in(33) XOR data_in(34) XOR data_in(35) XOR data_in(36) XOR data_in(37) XOR 
					data_in(38) XOR data_in(39) XOR data_in(40) XOR data_in(49) XOR data_in(50) XOR 
					data_in(51) XOR data_in(52) XOR data_in(53) XOR data_in(54) XOR data_in(55) XOR 
					data_in(56) XOR data_in(64) XOR data_in(65) XOR data_in(66) XOR data_in(67) XOR 
					data_in(68) XOR data_in(69) XOR data_in(70) XOR data_in(71) XOR data_in(80) XOR 
					data_in(81) XOR data_in(82) XOR data_in(83) XOR data_in(84) XOR data_in(85) XOR 
					data_in(86) XOR data_in(87) XOR data_in(96) XOR data_in(97) XOR data_in(98) XOR 
					data_in(99) XOR data_in(100) XOR data_in(101) XOR data_in(102) XOR data_in(103) XOR 
					data_in(112) XOR data_in(113) XOR data_in(114) XOR data_in(115) XOR data_in(116) XOR 
					data_in(117) XOR data_in(118) XOR data_in(119) XOR data_in(127) XOR data_in(128) XOR 
					data_in(129) XOR data_in(130) XOR data_in(131) XOR data_in(132) XOR data_in(133) XOR 
					data_in(134) XOR data_in(143) XOR data_in(144) XOR data_in(145) XOR data_in(146) XOR 
					data_in(147) XOR data_in(148) XOR data_in(149) XOR data_in(150) XOR data_in(159) XOR 
					data_in(160) XOR data_in(161) XOR data_in(162) XOR data_in(163) XOR data_in(164) XOR 
					data_in(165) XOR data_in(166) XOR data_in(175) XOR data_in(176) XOR data_in(177) XOR 
					data_in(178) XOR data_in(179) XOR data_in(180) XOR data_in(181) XOR data_in(182) XOR 
					data_in(191) XOR data_in(192) XOR data_in(193) XOR data_in(194) XOR data_in(195) XOR 
					data_in(196) XOR data_in(197) XOR data_in(198) XOR data_in(207) XOR data_in(208) XOR 
					data_in(209) XOR data_in(210) XOR data_in(211) XOR data_in(212) XOR data_in(213) XOR 
					data_in(214) XOR data_in(223) XOR data_in(224) XOR data_in(225) XOR data_in(226) XOR 
					data_in(227) XOR data_in(228) XOR data_in(229) XOR data_in(230) XOR data_in(239) XOR 
					data_in(240) XOR data_in(241) XOR data_in(242) XOR data_in(243) XOR data_in(244) XOR 
					data_in(245) XOR data_in(246) XOR data_in(254) XOR data_in(255) XOR data_in(256) XOR 
					data_in(257) XOR data_in(258) XOR data_in(259) XOR data_in(260) XOR data_in(261) XOR 
					data_in(270) XOR data_in(271) XOR data_in(272) XOR data_in(273) XOR data_in(274) XOR 
					data_in(275) XOR data_in(276) XOR data_in(277) XOR data_in(286) XOR data_in(287) XOR 
					data_in(288) XOR data_in(289) XOR data_in(290) XOR data_in(291) XOR data_in(292) XOR 
					data_in(293) XOR data_in(302) XOR data_in(303) XOR data_in(304) XOR data_in(305) XOR 
					data_in(306) XOR data_in(307) XOR data_in(308) XOR data_in(309) XOR data_in(318) XOR 
					data_in(319) XOR data_in(320) XOR data_in(321) XOR data_in(322) XOR data_in(323) XOR 
					data_in(324) XOR data_in(325) XOR data_in(334) XOR data_in(335) XOR data_in(336) XOR 
					data_in(337) XOR data_in(338) XOR data_in(339) XOR data_in(340) XOR data_in(341) XOR 
					data_in(350) XOR data_in(351) XOR data_in(352) XOR data_in(353) XOR data_in(354) XOR 
					data_in(355) XOR data_in(356) XOR data_in(357) XOR data_in(366) XOR data_in(367) XOR 
					data_in(368) XOR data_in(369) XOR data_in(370) XOR data_in(371) XOR data_in(372) XOR 
					data_in(373) XOR data_in(382) XOR data_in(383) XOR data_in(384) XOR data_in(385) XOR 
					data_in(386) XOR data_in(387) XOR data_in(388) XOR data_in(389) XOR data_in(398) XOR 
					data_in(399) XOR data_in(400) XOR data_in(401) XOR data_in(402) XOR data_in(403) XOR 
					data_in(404) XOR data_in(405) XOR data_in(414) XOR data_in(415) XOR data_in(416) XOR 
					data_in(417) XOR data_in(418) XOR data_in(419) XOR data_in(420) XOR data_in(421) XOR 
					data_in(430) XOR data_in(431) XOR data_in(432) XOR data_in(433) XOR data_in(434) XOR 
					data_in(435) XOR data_in(436) XOR data_in(437) XOR data_in(446) XOR data_in(447) XOR 
					data_in(448) XOR data_in(449) XOR data_in(450) XOR data_in(451) XOR data_in(452) XOR 
					data_in(453) XOR data_in(462) XOR data_in(463) XOR data_in(464) XOR data_in(465) XOR 
					data_in(466) XOR data_in(467) XOR data_in(468) XOR data_in(469) XOR data_in(478) XOR 
					data_in(479) XOR data_in(480) XOR data_in(481) XOR data_in(482) XOR data_in(483) XOR 
					data_in(484) XOR data_in(485) XOR data_in(494) XOR data_in(495);
   
	parity(3)	:=	data_in(1) XOR data_in(2) XOR data_in(3) XOR data_in(7) XOR data_in(8) XOR 
					data_in(9) XOR data_in(10) XOR data_in(14) XOR data_in(15) XOR data_in(16) XOR 
					data_in(17) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR data_in(25) XOR 
					data_in(29) XOR data_in(30) XOR data_in(31) XOR data_in(32) XOR data_in(37) XOR 
					data_in(38) XOR data_in(39) XOR data_in(40) XOR data_in(45) XOR data_in(46) XOR 
					data_in(47) XOR data_in(48) XOR data_in(53) XOR data_in(54) XOR data_in(55) XOR 
					data_in(56) XOR data_in(60) XOR data_in(61) XOR data_in(62) XOR data_in(63) XOR 
					data_in(68) XOR data_in(69) XOR data_in(70) XOR data_in(71) XOR data_in(76) XOR 
					data_in(77) XOR data_in(78) XOR data_in(79) XOR data_in(84) XOR data_in(85) XOR 
					data_in(86) XOR data_in(87) XOR data_in(92) XOR data_in(93) XOR data_in(94) XOR 
					data_in(95) XOR data_in(100) XOR data_in(101) XOR data_in(102) XOR data_in(103) XOR 
					data_in(108) XOR data_in(109) XOR data_in(110) XOR data_in(111) XOR data_in(116) XOR 
					data_in(117) XOR data_in(118) XOR data_in(119) XOR data_in(123) XOR data_in(124) XOR 
					data_in(125) XOR data_in(126) XOR data_in(131) XOR data_in(132) XOR data_in(133) XOR 
					data_in(134) XOR data_in(139) XOR data_in(140) XOR data_in(141) XOR data_in(142) XOR 
					data_in(147) XOR data_in(148) XOR data_in(149) XOR data_in(150) XOR data_in(155) XOR 
					data_in(156) XOR data_in(157) XOR data_in(158) XOR data_in(163) XOR data_in(164) XOR 
					data_in(165) XOR data_in(166) XOR data_in(171) XOR data_in(172) XOR data_in(173) XOR 
					data_in(174) XOR data_in(179) XOR data_in(180) XOR data_in(181) XOR data_in(182) XOR 
					data_in(187) XOR data_in(188) XOR data_in(189) XOR data_in(190) XOR data_in(195) XOR 
					data_in(196) XOR data_in(197) XOR data_in(198) XOR data_in(203) XOR data_in(204) XOR 
					data_in(205) XOR data_in(206) XOR data_in(211) XOR data_in(212) XOR data_in(213) XOR 
					data_in(214) XOR data_in(219) XOR data_in(220) XOR data_in(221) XOR data_in(222) XOR 
					data_in(227) XOR data_in(228) XOR data_in(229) XOR data_in(230) XOR data_in(235) XOR 
					data_in(236) XOR data_in(237) XOR data_in(238) XOR data_in(243) XOR data_in(244) XOR 
					data_in(245) XOR data_in(246) XOR data_in(250) XOR data_in(251) XOR data_in(252) XOR 
					data_in(253) XOR data_in(258) XOR data_in(259) XOR data_in(260) XOR data_in(261) XOR 
					data_in(266) XOR data_in(267) XOR data_in(268) XOR data_in(269) XOR data_in(274) XOR 
					data_in(275) XOR data_in(276) XOR data_in(277) XOR data_in(282) XOR data_in(283) XOR 
					data_in(284) XOR data_in(285) XOR data_in(290) XOR data_in(291) XOR data_in(292) XOR 
					data_in(293) XOR data_in(298) XOR data_in(299) XOR data_in(300) XOR data_in(301) XOR 
					data_in(306) XOR data_in(307) XOR data_in(308) XOR data_in(309) XOR data_in(314) XOR 
					data_in(315) XOR data_in(316) XOR data_in(317) XOR data_in(322) XOR data_in(323) XOR 
					data_in(324) XOR data_in(325) XOR data_in(330) XOR data_in(331) XOR data_in(332) XOR 
					data_in(333) XOR data_in(338) XOR data_in(339) XOR data_in(340) XOR data_in(341) XOR 
					data_in(346) XOR data_in(347) XOR data_in(348) XOR data_in(349) XOR data_in(354) XOR 
					data_in(355) XOR data_in(356) XOR data_in(357) XOR data_in(362) XOR data_in(363) XOR 
					data_in(364) XOR data_in(365) XOR data_in(370) XOR data_in(371) XOR data_in(372) XOR 
					data_in(373) XOR data_in(378) XOR data_in(379) XOR data_in(380) XOR data_in(381) XOR 
					data_in(386) XOR data_in(387) XOR data_in(388) XOR data_in(389) XOR data_in(394) XOR 
					data_in(395) XOR data_in(396) XOR data_in(397) XOR data_in(402) XOR data_in(403) XOR 
					data_in(404) XOR data_in(405) XOR data_in(410) XOR data_in(411) XOR data_in(412) XOR 
					data_in(413) XOR data_in(418) XOR data_in(419) XOR data_in(420) XOR data_in(421) XOR 
					data_in(426) XOR data_in(427) XOR data_in(428) XOR data_in(429) XOR data_in(434) XOR 
					data_in(435) XOR data_in(436) XOR data_in(437) XOR data_in(442) XOR data_in(443) XOR 
					data_in(444) XOR data_in(445) XOR data_in(450) XOR data_in(451) XOR data_in(452) XOR 
					data_in(453) XOR data_in(458) XOR data_in(459) XOR data_in(460) XOR data_in(461) XOR 
					data_in(466) XOR data_in(467) XOR data_in(468) XOR data_in(469) XOR data_in(474) XOR 
					data_in(475) XOR data_in(476) XOR data_in(477) XOR data_in(482) XOR data_in(483) XOR 
					data_in(484) XOR data_in(485) XOR data_in(490) XOR data_in(491) XOR data_in(492) XOR 
					data_in(493);
   
	parity(2)	:=	data_in(0) XOR data_in(2) XOR data_in(3) XOR data_in(5) XOR data_in(6) XOR 
					data_in(9) XOR data_in(10) XOR data_in(12) XOR data_in(13) XOR data_in(16) XOR 
					data_in(17) XOR data_in(20) XOR data_in(21) XOR data_in(24) XOR data_in(25) XOR 
					data_in(27) XOR data_in(28) XOR data_in(31) XOR data_in(32) XOR data_in(35) XOR 
					data_in(36) XOR data_in(39) XOR data_in(40) XOR data_in(43) XOR data_in(44) XOR 
					data_in(47) XOR data_in(48) XOR data_in(51) XOR data_in(52) XOR data_in(55) XOR 
					data_in(56) XOR data_in(58) XOR data_in(59) XOR data_in(62) XOR data_in(63) XOR 
					data_in(66) XOR data_in(67) XOR data_in(70) XOR data_in(71) XOR data_in(74) XOR 
					data_in(75) XOR data_in(78) XOR data_in(79) XOR data_in(82) XOR data_in(83) XOR 
					data_in(86) XOR data_in(87) XOR data_in(90) XOR data_in(91) XOR data_in(94) XOR 
					data_in(95) XOR data_in(98) XOR data_in(99) XOR data_in(102) XOR data_in(103) XOR 
					data_in(106) XOR data_in(107) XOR data_in(110) XOR data_in(111) XOR data_in(114) XOR 
					data_in(115) XOR data_in(118) XOR data_in(119) XOR data_in(121) XOR data_in(122) XOR 
					data_in(125) XOR data_in(126) XOR data_in(129) XOR data_in(130) XOR data_in(133) XOR 
					data_in(134) XOR data_in(137) XOR data_in(138) XOR data_in(141) XOR data_in(142) XOR 
					data_in(145) XOR data_in(146) XOR data_in(149) XOR data_in(150) XOR data_in(153) XOR 
					data_in(154) XOR data_in(157) XOR data_in(158) XOR data_in(161) XOR data_in(162) XOR 
					data_in(165) XOR data_in(166) XOR data_in(169) XOR data_in(170) XOR data_in(173) XOR 
					data_in(174) XOR data_in(177) XOR data_in(178) XOR data_in(181) XOR data_in(182) XOR 
					data_in(185) XOR data_in(186) XOR data_in(189) XOR data_in(190) XOR data_in(193) XOR 
					data_in(194) XOR data_in(197) XOR data_in(198) XOR data_in(201) XOR data_in(202) XOR 
					data_in(205) XOR data_in(206) XOR data_in(209) XOR data_in(210) XOR data_in(213) XOR 
					data_in(214) XOR data_in(217) XOR data_in(218) XOR data_in(221) XOR data_in(222) XOR 
					data_in(225) XOR data_in(226) XOR data_in(229) XOR data_in(230) XOR data_in(233) XOR 
					data_in(234) XOR data_in(237) XOR data_in(238) XOR data_in(241) XOR data_in(242) XOR 
					data_in(245) XOR data_in(246) XOR data_in(248) XOR data_in(249) XOR data_in(252) XOR 
					data_in(253) XOR data_in(256) XOR data_in(257) XOR data_in(260) XOR data_in(261) XOR 
					data_in(264) XOR data_in(265) XOR data_in(268) XOR data_in(269) XOR data_in(272) XOR 
					data_in(273) XOR data_in(276) XOR data_in(277) XOR data_in(280) XOR data_in(281) XOR 
					data_in(284) XOR data_in(285) XOR data_in(288) XOR data_in(289) XOR data_in(292) XOR 
					data_in(293) XOR data_in(296) XOR data_in(297) XOR data_in(300) XOR data_in(301) XOR 
					data_in(304) XOR data_in(305) XOR data_in(308) XOR data_in(309) XOR data_in(312) XOR 
					data_in(313) XOR data_in(316) XOR data_in(317) XOR data_in(320) XOR data_in(321) XOR 
					data_in(324) XOR data_in(325) XOR data_in(328) XOR data_in(329) XOR data_in(332) XOR 
					data_in(333) XOR data_in(336) XOR data_in(337) XOR data_in(340) XOR data_in(341) XOR 
					data_in(344) XOR data_in(345) XOR data_in(348) XOR data_in(349) XOR data_in(352) XOR 
					data_in(353) XOR data_in(356) XOR data_in(357) XOR data_in(360) XOR data_in(361) XOR 
					data_in(364) XOR data_in(365) XOR data_in(368) XOR data_in(369) XOR data_in(372) XOR 
					data_in(373) XOR data_in(376) XOR data_in(377) XOR data_in(380) XOR data_in(381) XOR 
					data_in(384) XOR data_in(385) XOR data_in(388) XOR data_in(389) XOR data_in(392) XOR 
					data_in(393) XOR data_in(396) XOR data_in(397) XOR data_in(400) XOR data_in(401) XOR 
					data_in(404) XOR data_in(405) XOR data_in(408) XOR data_in(409) XOR data_in(412) XOR 
					data_in(413) XOR data_in(416) XOR data_in(417) XOR data_in(420) XOR data_in(421) XOR 
					data_in(424) XOR data_in(425) XOR data_in(428) XOR data_in(429) XOR data_in(432) XOR 
					data_in(433) XOR data_in(436) XOR data_in(437) XOR data_in(440) XOR data_in(441) XOR 
					data_in(444) XOR data_in(445) XOR data_in(448) XOR data_in(449) XOR data_in(452) XOR 
					data_in(453) XOR data_in(456) XOR data_in(457) XOR data_in(460) XOR data_in(461) XOR 
					data_in(464) XOR data_in(465) XOR data_in(468) XOR data_in(469) XOR data_in(472) XOR 
					data_in(473) XOR data_in(476) XOR data_in(477) XOR data_in(480) XOR data_in(481) XOR 
					data_in(484) XOR data_in(485) XOR data_in(488) XOR data_in(489) XOR data_in(492) XOR 
					data_in(493);
   
	parity(1)	:=	data_in(0) XOR data_in(1) XOR data_in(3) XOR data_in(4) XOR data_in(6) XOR 
					data_in(8) XOR data_in(10) XOR data_in(11) XOR data_in(13) XOR data_in(15) XOR 
					data_in(17) XOR data_in(19) XOR data_in(21) XOR data_in(23) XOR data_in(25) XOR 
					data_in(26) XOR data_in(28) XOR data_in(30) XOR data_in(32) XOR data_in(34) XOR 
					data_in(36) XOR data_in(38) XOR data_in(40) XOR data_in(42) XOR data_in(44) XOR 
					data_in(46) XOR data_in(48) XOR data_in(50) XOR data_in(52) XOR data_in(54) XOR 
					data_in(56) XOR data_in(57) XOR data_in(59) XOR data_in(61) XOR data_in(63) XOR 
					data_in(65) XOR data_in(67) XOR data_in(69) XOR data_in(71) XOR data_in(73) XOR 
					data_in(75) XOR data_in(77) XOR data_in(79) XOR data_in(81) XOR data_in(83) XOR 
					data_in(85) XOR data_in(87) XOR data_in(89) XOR data_in(91) XOR data_in(93) XOR 
					data_in(95) XOR data_in(97) XOR data_in(99) XOR data_in(101) XOR data_in(103) XOR 
					data_in(105) XOR data_in(107) XOR data_in(109) XOR data_in(111) XOR data_in(113) XOR 
					data_in(115) XOR data_in(117) XOR data_in(119) XOR data_in(120) XOR data_in(122) XOR 
					data_in(124) XOR data_in(126) XOR data_in(128) XOR data_in(130) XOR data_in(132) XOR 
					data_in(134) XOR data_in(136) XOR data_in(138) XOR data_in(140) XOR data_in(142) XOR 
					data_in(144) XOR data_in(146) XOR data_in(148) XOR data_in(150) XOR data_in(152) XOR 
					data_in(154) XOR data_in(156) XOR data_in(158) XOR data_in(160) XOR data_in(162) XOR 
					data_in(164) XOR data_in(166) XOR data_in(168) XOR data_in(170) XOR data_in(172) XOR 
					data_in(174) XOR data_in(176) XOR data_in(178) XOR data_in(180) XOR data_in(182) XOR 
					data_in(184) XOR data_in(186) XOR data_in(188) XOR data_in(190) XOR data_in(192) XOR 
					data_in(194) XOR data_in(196) XOR data_in(198) XOR data_in(200) XOR data_in(202) XOR 
					data_in(204) XOR data_in(206) XOR data_in(208) XOR data_in(210) XOR data_in(212) XOR 
					data_in(214) XOR data_in(216) XOR data_in(218) XOR data_in(220) XOR data_in(222) XOR 
					data_in(224) XOR data_in(226) XOR data_in(228) XOR data_in(230) XOR data_in(232) XOR 
					data_in(234) XOR data_in(236) XOR data_in(238) XOR data_in(240) XOR data_in(242) XOR 
					data_in(244) XOR data_in(246) XOR data_in(247) XOR data_in(249) XOR data_in(251) XOR 
					data_in(253) XOR data_in(255) XOR data_in(257) XOR data_in(259) XOR data_in(261) XOR 
					data_in(263) XOR data_in(265) XOR data_in(267) XOR data_in(269) XOR data_in(271) XOR 
					data_in(273) XOR data_in(275) XOR data_in(277) XOR data_in(279) XOR data_in(281) XOR 
					data_in(283) XOR data_in(285) XOR data_in(287) XOR data_in(289) XOR data_in(291) XOR 
					data_in(293) XOR data_in(295) XOR data_in(297) XOR data_in(299) XOR data_in(301) XOR 
					data_in(303) XOR data_in(305) XOR data_in(307) XOR data_in(309) XOR data_in(311) XOR 
					data_in(313) XOR data_in(315) XOR data_in(317) XOR data_in(319) XOR data_in(321) XOR 
					data_in(323) XOR data_in(325) XOR data_in(327) XOR data_in(329) XOR data_in(331) XOR 
					data_in(333) XOR data_in(335) XOR data_in(337) XOR data_in(339) XOR data_in(341) XOR 
					data_in(343) XOR data_in(345) XOR data_in(347) XOR data_in(349) XOR data_in(351) XOR 
					data_in(353) XOR data_in(355) XOR data_in(357) XOR data_in(359) XOR data_in(361) XOR 
					data_in(363) XOR data_in(365) XOR data_in(367) XOR data_in(369) XOR data_in(371) XOR 
					data_in(373) XOR data_in(375) XOR data_in(377) XOR data_in(379) XOR data_in(381) XOR 
					data_in(383) XOR data_in(385) XOR data_in(387) XOR data_in(389) XOR data_in(391) XOR 
					data_in(393) XOR data_in(395) XOR data_in(397) XOR data_in(399) XOR data_in(401) XOR 
					data_in(403) XOR data_in(405) XOR data_in(407) XOR data_in(409) XOR data_in(411) XOR 
					data_in(413) XOR data_in(415) XOR data_in(417) XOR data_in(419) XOR data_in(421) XOR 
					data_in(423) XOR data_in(425) XOR data_in(427) XOR data_in(429) XOR data_in(431) XOR 
					data_in(433) XOR data_in(435) XOR data_in(437) XOR data_in(439) XOR data_in(441) XOR 
					data_in(443) XOR data_in(445) XOR data_in(447) XOR data_in(449) XOR data_in(451) XOR 
					data_in(453) XOR data_in(455) XOR data_in(457) XOR data_in(459) XOR data_in(461) XOR 
					data_in(463) XOR data_in(465) XOR data_in(467) XOR data_in(469) XOR data_in(471) XOR 
					data_in(473) XOR data_in(475) XOR data_in(477) XOR data_in(479) XOR data_in(481) XOR 
					data_in(483) XOR data_in(485) XOR data_in(487) XOR data_in(489) XOR data_in(491) XOR 
					data_in(493) XOR data_in(495);
   
	parity(0)	:=	data_in(0) XOR data_in(1) XOR data_in(2) XOR data_in(3) XOR data_in(4) XOR 
					data_in(5) XOR data_in(6) XOR data_in(7) XOR data_in(8) XOR data_in(9) XOR 
					data_in(10) XOR data_in(11) XOR data_in(12) XOR data_in(13) XOR data_in(14) XOR 
					data_in(15) XOR data_in(16) XOR data_in(17) XOR data_in(18) XOR data_in(19) XOR 
					data_in(20) XOR data_in(21) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR 
					data_in(25) XOR data_in(26) XOR data_in(27) XOR data_in(28) XOR data_in(29) XOR 
					data_in(30) XOR data_in(31) XOR data_in(32) XOR data_in(33) XOR data_in(34) XOR 
					data_in(35) XOR data_in(36) XOR data_in(37) XOR data_in(38) XOR data_in(39) XOR 
					data_in(40) XOR data_in(41) XOR data_in(42) XOR data_in(43) XOR data_in(44) XOR 
					data_in(45) XOR data_in(46) XOR data_in(47) XOR data_in(48) XOR data_in(49) XOR 
					data_in(50) XOR data_in(51) XOR data_in(52) XOR data_in(53) XOR data_in(54) XOR 
					data_in(55) XOR data_in(56) XOR data_in(57) XOR data_in(58) XOR data_in(59) XOR 
					data_in(60) XOR data_in(61) XOR data_in(62) XOR data_in(63) XOR data_in(64) XOR 
					data_in(65) XOR data_in(66) XOR data_in(67) XOR data_in(68) XOR data_in(69) XOR 
					data_in(70) XOR data_in(71) XOR data_in(72) XOR data_in(73) XOR data_in(74) XOR 
					data_in(75) XOR data_in(76) XOR data_in(77) XOR data_in(78) XOR data_in(79) XOR 
					data_in(80) XOR data_in(81) XOR data_in(82) XOR data_in(83) XOR data_in(84) XOR 
					data_in(85) XOR data_in(86) XOR data_in(87) XOR data_in(88) XOR data_in(89) XOR 
					data_in(90) XOR data_in(91) XOR data_in(92) XOR data_in(93) XOR data_in(94) XOR 
					data_in(95) XOR data_in(96) XOR data_in(97) XOR data_in(98) XOR data_in(99) XOR 
					data_in(100) XOR data_in(101) XOR data_in(102) XOR data_in(103) XOR data_in(104) XOR 
					data_in(105) XOR data_in(106) XOR data_in(107) XOR data_in(108) XOR data_in(109) XOR 
					data_in(110) XOR data_in(111) XOR data_in(112) XOR data_in(113) XOR data_in(114) XOR 
					data_in(115) XOR data_in(116) XOR data_in(117) XOR data_in(118) XOR data_in(119) XOR 
					data_in(120) XOR data_in(121) XOR data_in(122) XOR data_in(123) XOR data_in(124) XOR 
					data_in(125) XOR data_in(126) XOR data_in(127) XOR data_in(128) XOR data_in(129) XOR 
					data_in(130) XOR data_in(131) XOR data_in(132) XOR data_in(133) XOR data_in(134) XOR 
					data_in(135) XOR data_in(136) XOR data_in(137) XOR data_in(138) XOR data_in(139) XOR 
					data_in(140) XOR data_in(141) XOR data_in(142) XOR data_in(143) XOR data_in(144) XOR 
					data_in(145) XOR data_in(146) XOR data_in(147) XOR data_in(148) XOR data_in(149) XOR 
					data_in(150) XOR data_in(151) XOR data_in(152) XOR data_in(153) XOR data_in(154) XOR 
					data_in(155) XOR data_in(156) XOR data_in(157) XOR data_in(158) XOR data_in(159) XOR 
					data_in(160) XOR data_in(161) XOR data_in(162) XOR data_in(163) XOR data_in(164) XOR 
					data_in(165) XOR data_in(166) XOR data_in(167) XOR data_in(168) XOR data_in(169) XOR 
					data_in(170) XOR data_in(171) XOR data_in(172) XOR data_in(173) XOR data_in(174) XOR 
					data_in(175) XOR data_in(176) XOR data_in(177) XOR data_in(178) XOR data_in(179) XOR 
					data_in(180) XOR data_in(181) XOR data_in(182) XOR data_in(183) XOR data_in(184) XOR 
					data_in(185) XOR data_in(186) XOR data_in(187) XOR data_in(188) XOR data_in(189) XOR 
					data_in(190) XOR data_in(191) XOR data_in(192) XOR data_in(193) XOR data_in(194) XOR 
					data_in(195) XOR data_in(196) XOR data_in(197) XOR data_in(198) XOR data_in(199) XOR 
					data_in(200) XOR data_in(201) XOR data_in(202) XOR data_in(203) XOR data_in(204) XOR 
					data_in(205) XOR data_in(206) XOR data_in(207) XOR data_in(208) XOR data_in(209) XOR 
					data_in(210) XOR data_in(211) XOR data_in(212) XOR data_in(213) XOR data_in(214) XOR 
					data_in(215) XOR data_in(216) XOR data_in(217) XOR data_in(218) XOR data_in(219) XOR 
					data_in(220) XOR data_in(221) XOR data_in(222) XOR data_in(223) XOR data_in(224) XOR 
					data_in(225) XOR data_in(226) XOR data_in(227) XOR data_in(228) XOR data_in(229) XOR 
					data_in(230) XOR data_in(231) XOR data_in(232) XOR data_in(233) XOR data_in(234) XOR 
					data_in(235) XOR data_in(236) XOR data_in(237) XOR data_in(238) XOR data_in(239) XOR 
					data_in(240) XOR data_in(241) XOR data_in(242) XOR data_in(243) XOR data_in(244) XOR 
					data_in(245) XOR data_in(246) XOR data_in(247) XOR data_in(248) XOR data_in(249) XOR 
					data_in(250) XOR data_in(251) XOR data_in(252) XOR data_in(253) XOR data_in(254) XOR 
					data_in(255) XOR data_in(256) XOR data_in(257) XOR data_in(258) XOR data_in(259) XOR 
					data_in(260) XOR data_in(261) XOR data_in(262) XOR data_in(263) XOR data_in(264) XOR 
					data_in(265) XOR data_in(266) XOR data_in(267) XOR data_in(268) XOR data_in(269) XOR 
					data_in(270) XOR data_in(271) XOR data_in(272) XOR data_in(273) XOR data_in(274) XOR 
					data_in(275) XOR data_in(276) XOR data_in(277) XOR data_in(278) XOR data_in(279) XOR 
					data_in(280) XOR data_in(281) XOR data_in(282) XOR data_in(283) XOR data_in(284) XOR 
					data_in(285) XOR data_in(286) XOR data_in(287) XOR data_in(288) XOR data_in(289) XOR 
					data_in(290) XOR data_in(291) XOR data_in(292) XOR data_in(293) XOR data_in(294) XOR 
					data_in(295) XOR data_in(296) XOR data_in(297) XOR data_in(298) XOR data_in(299) XOR 
					data_in(300) XOR data_in(301) XOR data_in(302) XOR data_in(303) XOR data_in(304) XOR 
					data_in(305) XOR data_in(306) XOR data_in(307) XOR data_in(308) XOR data_in(309) XOR 
					data_in(310) XOR data_in(311) XOR data_in(312) XOR data_in(313) XOR data_in(314) XOR 
					data_in(315) XOR data_in(316) XOR data_in(317) XOR data_in(318) XOR data_in(319) XOR 
					data_in(320) XOR data_in(321) XOR data_in(322) XOR data_in(323) XOR data_in(324) XOR 
					data_in(325) XOR data_in(326) XOR data_in(327) XOR data_in(328) XOR data_in(329) XOR 
					data_in(330) XOR data_in(331) XOR data_in(332) XOR data_in(333) XOR data_in(334) XOR 
					data_in(335) XOR data_in(336) XOR data_in(337) XOR data_in(338) XOR data_in(339) XOR 
					data_in(340) XOR data_in(341) XOR data_in(342) XOR data_in(343) XOR data_in(344) XOR 
					data_in(345) XOR data_in(346) XOR data_in(347) XOR data_in(348) XOR data_in(349) XOR 
					data_in(350) XOR data_in(351) XOR data_in(352) XOR data_in(353) XOR data_in(354) XOR 
					data_in(355) XOR data_in(356) XOR data_in(357) XOR data_in(358) XOR data_in(359) XOR 
					data_in(360) XOR data_in(361) XOR data_in(362) XOR data_in(363) XOR data_in(364) XOR 
					data_in(365) XOR data_in(366) XOR data_in(367) XOR data_in(368) XOR data_in(369) XOR 
					data_in(370) XOR data_in(371) XOR data_in(372) XOR data_in(373) XOR data_in(374) XOR 
					data_in(375) XOR data_in(376) XOR data_in(377) XOR data_in(378) XOR data_in(379) XOR 
					data_in(380) XOR data_in(381) XOR data_in(382) XOR data_in(383) XOR data_in(384) XOR 
					data_in(385) XOR data_in(386) XOR data_in(387) XOR data_in(388) XOR data_in(389) XOR 
					data_in(390) XOR data_in(391) XOR data_in(392) XOR data_in(393) XOR data_in(394) XOR 
					data_in(395) XOR data_in(396) XOR data_in(397) XOR data_in(398) XOR data_in(399) XOR 
					data_in(400) XOR data_in(401) XOR data_in(402) XOR data_in(403) XOR data_in(404) XOR 
					data_in(405) XOR data_in(406) XOR data_in(407) XOR data_in(408) XOR data_in(409) XOR 
					data_in(410) XOR data_in(411) XOR data_in(412) XOR data_in(413) XOR data_in(414) XOR 
					data_in(415) XOR data_in(416) XOR data_in(417) XOR data_in(418) XOR data_in(419) XOR 
					data_in(420) XOR data_in(421) XOR data_in(422) XOR data_in(423) XOR data_in(424) XOR 
					data_in(425) XOR data_in(426) XOR data_in(427) XOR data_in(428) XOR data_in(429) XOR 
					data_in(430) XOR data_in(431) XOR data_in(432) XOR data_in(433) XOR data_in(434) XOR 
					data_in(435) XOR data_in(436) XOR data_in(437) XOR data_in(438) XOR data_in(439) XOR 
					data_in(440) XOR data_in(441) XOR data_in(442) XOR data_in(443) XOR data_in(444) XOR 
					data_in(445) XOR data_in(446) XOR data_in(447) XOR data_in(448) XOR data_in(449) XOR 
					data_in(450) XOR data_in(451) XOR data_in(452) XOR data_in(453) XOR data_in(454) XOR 
					data_in(455) XOR data_in(456) XOR data_in(457) XOR data_in(458) XOR data_in(459) XOR 
					data_in(460) XOR data_in(461) XOR data_in(462) XOR data_in(463) XOR data_in(464) XOR 
					data_in(465) XOR data_in(466) XOR data_in(467) XOR data_in(468) XOR data_in(469) XOR 
					data_in(470) XOR data_in(471) XOR data_in(472) XOR data_in(473) XOR data_in(474) XOR 
					data_in(475) XOR data_in(476) XOR data_in(477) XOR data_in(478) XOR data_in(479) XOR 
					data_in(480) XOR data_in(481) XOR data_in(482) XOR data_in(483) XOR data_in(484) XOR 
					data_in(485) XOR data_in(486) XOR data_in(487) XOR data_in(488) XOR data_in(489) XOR 
					data_in(490) XOR data_in(491) XOR data_in(492) XOR data_in(493) XOR data_in(494) XOR 
					data_in(495) XOR parity(1) XOR parity(2) XOR parity(3) XOR parity(4) XOR 
					parity(5) XOR parity(6) XOR parity(7) XOR parity(8) XOR parity(9) 
					;


	RETURN parity;
END;

---------------------
-- HAMMING DECODER --
---------------------
PROCEDURE hamming_decoder_496bit(data_parity_in:coded_ham_496bit;
		SIGNAL error_out : OUT std_logic_vector(1 DOWNTO 0);
		SIGNAL decoded   : OUT data_ham_496bit) IS
	VARIABLE coded       : coded_ham_496bit;
	VARIABLE syndrome    : integer RANGE 0 TO 505;
	VARIABLE parity      : parity_ham_496bit;
	VARIABLE parity_in   : parity_ham_496bit;
	VARIABLE syn         : parity_ham_496bit;
	VARIABLE data_in     : data_ham_496bit;
	VARIABLE P0, P1      : std_logic;
BEGIN

	data_in   := data_parity_in(505 DOWNTO 10);
	parity_in := data_parity_in(9 DOWNTO 0);

	parity(9)	:=	data_in(247) XOR data_in(248) XOR data_in(249) XOR data_in(250) XOR data_in(251) XOR 
					data_in(252) XOR data_in(253) XOR data_in(254) XOR data_in(255) XOR data_in(256) XOR 
					data_in(257) XOR data_in(258) XOR data_in(259) XOR data_in(260) XOR data_in(261) XOR 
					data_in(262) XOR data_in(263) XOR data_in(264) XOR data_in(265) XOR data_in(266) XOR 
					data_in(267) XOR data_in(268) XOR data_in(269) XOR data_in(270) XOR data_in(271) XOR 
					data_in(272) XOR data_in(273) XOR data_in(274) XOR data_in(275) XOR data_in(276) XOR 
					data_in(277) XOR data_in(278) XOR data_in(279) XOR data_in(280) XOR data_in(281) XOR 
					data_in(282) XOR data_in(283) XOR data_in(284) XOR data_in(285) XOR data_in(286) XOR 
					data_in(287) XOR data_in(288) XOR data_in(289) XOR data_in(290) XOR data_in(291) XOR 
					data_in(292) XOR data_in(293) XOR data_in(294) XOR data_in(295) XOR data_in(296) XOR 
					data_in(297) XOR data_in(298) XOR data_in(299) XOR data_in(300) XOR data_in(301) XOR 
					data_in(302) XOR data_in(303) XOR data_in(304) XOR data_in(305) XOR data_in(306) XOR 
					data_in(307) XOR data_in(308) XOR data_in(309) XOR data_in(310) XOR data_in(311) XOR 
					data_in(312) XOR data_in(313) XOR data_in(314) XOR data_in(315) XOR data_in(316) XOR 
					data_in(317) XOR data_in(318) XOR data_in(319) XOR data_in(320) XOR data_in(321) XOR 
					data_in(322) XOR data_in(323) XOR data_in(324) XOR data_in(325) XOR data_in(326) XOR 
					data_in(327) XOR data_in(328) XOR data_in(329) XOR data_in(330) XOR data_in(331) XOR 
					data_in(332) XOR data_in(333) XOR data_in(334) XOR data_in(335) XOR data_in(336) XOR 
					data_in(337) XOR data_in(338) XOR data_in(339) XOR data_in(340) XOR data_in(341) XOR 
					data_in(342) XOR data_in(343) XOR data_in(344) XOR data_in(345) XOR data_in(346) XOR 
					data_in(347) XOR data_in(348) XOR data_in(349) XOR data_in(350) XOR data_in(351) XOR 
					data_in(352) XOR data_in(353) XOR data_in(354) XOR data_in(355) XOR data_in(356) XOR 
					data_in(357) XOR data_in(358) XOR data_in(359) XOR data_in(360) XOR data_in(361) XOR 
					data_in(362) XOR data_in(363) XOR data_in(364) XOR data_in(365) XOR data_in(366) XOR 
					data_in(367) XOR data_in(368) XOR data_in(369) XOR data_in(370) XOR data_in(371) XOR 
					data_in(372) XOR data_in(373) XOR data_in(374) XOR data_in(375) XOR data_in(376) XOR 
					data_in(377) XOR data_in(378) XOR data_in(379) XOR data_in(380) XOR data_in(381) XOR 
					data_in(382) XOR data_in(383) XOR data_in(384) XOR data_in(385) XOR data_in(386) XOR 
					data_in(387) XOR data_in(388) XOR data_in(389) XOR data_in(390) XOR data_in(391) XOR 
					data_in(392) XOR data_in(393) XOR data_in(394) XOR data_in(395) XOR data_in(396) XOR 
					data_in(397) XOR data_in(398) XOR data_in(399) XOR data_in(400) XOR data_in(401) XOR 
					data_in(402) XOR data_in(403) XOR data_in(404) XOR data_in(405) XOR data_in(406) XOR 
					data_in(407) XOR data_in(408) XOR data_in(409) XOR data_in(410) XOR data_in(411) XOR 
					data_in(412) XOR data_in(413) XOR data_in(414) XOR data_in(415) XOR data_in(416) XOR 
					data_in(417) XOR data_in(418) XOR data_in(419) XOR data_in(420) XOR data_in(421) XOR 
					data_in(422) XOR data_in(423) XOR data_in(424) XOR data_in(425) XOR data_in(426) XOR 
					data_in(427) XOR data_in(428) XOR data_in(429) XOR data_in(430) XOR data_in(431) XOR 
					data_in(432) XOR data_in(433) XOR data_in(434) XOR data_in(435) XOR data_in(436) XOR 
					data_in(437) XOR data_in(438) XOR data_in(439) XOR data_in(440) XOR data_in(441) XOR 
					data_in(442) XOR data_in(443) XOR data_in(444) XOR data_in(445) XOR data_in(446) XOR 
					data_in(447) XOR data_in(448) XOR data_in(449) XOR data_in(450) XOR data_in(451) XOR 
					data_in(452) XOR data_in(453) XOR data_in(454) XOR data_in(455) XOR data_in(456) XOR 
					data_in(457) XOR data_in(458) XOR data_in(459) XOR data_in(460) XOR data_in(461) XOR 
					data_in(462) XOR data_in(463) XOR data_in(464) XOR data_in(465) XOR data_in(466) XOR 
					data_in(467) XOR data_in(468) XOR data_in(469) XOR data_in(470) XOR data_in(471) XOR 
					data_in(472) XOR data_in(473) XOR data_in(474) XOR data_in(475) XOR data_in(476) XOR 
					data_in(477) XOR data_in(478) XOR data_in(479) XOR data_in(480) XOR data_in(481) XOR 
					data_in(482) XOR data_in(483) XOR data_in(484) XOR data_in(485) XOR data_in(486) XOR 
					data_in(487) XOR data_in(488) XOR data_in(489) XOR data_in(490) XOR data_in(491) XOR 
					data_in(492) XOR data_in(493) XOR data_in(494) XOR data_in(495);
   
	parity(8)	:=	data_in(120) XOR data_in(121) XOR data_in(122) XOR data_in(123) XOR data_in(124) XOR 
					data_in(125) XOR data_in(126) XOR data_in(127) XOR data_in(128) XOR data_in(129) XOR 
					data_in(130) XOR data_in(131) XOR data_in(132) XOR data_in(133) XOR data_in(134) XOR 
					data_in(135) XOR data_in(136) XOR data_in(137) XOR data_in(138) XOR data_in(139) XOR 
					data_in(140) XOR data_in(141) XOR data_in(142) XOR data_in(143) XOR data_in(144) XOR 
					data_in(145) XOR data_in(146) XOR data_in(147) XOR data_in(148) XOR data_in(149) XOR 
					data_in(150) XOR data_in(151) XOR data_in(152) XOR data_in(153) XOR data_in(154) XOR 
					data_in(155) XOR data_in(156) XOR data_in(157) XOR data_in(158) XOR data_in(159) XOR 
					data_in(160) XOR data_in(161) XOR data_in(162) XOR data_in(163) XOR data_in(164) XOR 
					data_in(165) XOR data_in(166) XOR data_in(167) XOR data_in(168) XOR data_in(169) XOR 
					data_in(170) XOR data_in(171) XOR data_in(172) XOR data_in(173) XOR data_in(174) XOR 
					data_in(175) XOR data_in(176) XOR data_in(177) XOR data_in(178) XOR data_in(179) XOR 
					data_in(180) XOR data_in(181) XOR data_in(182) XOR data_in(183) XOR data_in(184) XOR 
					data_in(185) XOR data_in(186) XOR data_in(187) XOR data_in(188) XOR data_in(189) XOR 
					data_in(190) XOR data_in(191) XOR data_in(192) XOR data_in(193) XOR data_in(194) XOR 
					data_in(195) XOR data_in(196) XOR data_in(197) XOR data_in(198) XOR data_in(199) XOR 
					data_in(200) XOR data_in(201) XOR data_in(202) XOR data_in(203) XOR data_in(204) XOR 
					data_in(205) XOR data_in(206) XOR data_in(207) XOR data_in(208) XOR data_in(209) XOR 
					data_in(210) XOR data_in(211) XOR data_in(212) XOR data_in(213) XOR data_in(214) XOR 
					data_in(215) XOR data_in(216) XOR data_in(217) XOR data_in(218) XOR data_in(219) XOR 
					data_in(220) XOR data_in(221) XOR data_in(222) XOR data_in(223) XOR data_in(224) XOR 
					data_in(225) XOR data_in(226) XOR data_in(227) XOR data_in(228) XOR data_in(229) XOR 
					data_in(230) XOR data_in(231) XOR data_in(232) XOR data_in(233) XOR data_in(234) XOR 
					data_in(235) XOR data_in(236) XOR data_in(237) XOR data_in(238) XOR data_in(239) XOR 
					data_in(240) XOR data_in(241) XOR data_in(242) XOR data_in(243) XOR data_in(244) XOR 
					data_in(245) XOR data_in(246) XOR data_in(374) XOR data_in(375) XOR data_in(376) XOR 
					data_in(377) XOR data_in(378) XOR data_in(379) XOR data_in(380) XOR data_in(381) XOR 
					data_in(382) XOR data_in(383) XOR data_in(384) XOR data_in(385) XOR data_in(386) XOR 
					data_in(387) XOR data_in(388) XOR data_in(389) XOR data_in(390) XOR data_in(391) XOR 
					data_in(392) XOR data_in(393) XOR data_in(394) XOR data_in(395) XOR data_in(396) XOR 
					data_in(397) XOR data_in(398) XOR data_in(399) XOR data_in(400) XOR data_in(401) XOR 
					data_in(402) XOR data_in(403) XOR data_in(404) XOR data_in(405) XOR data_in(406) XOR 
					data_in(407) XOR data_in(408) XOR data_in(409) XOR data_in(410) XOR data_in(411) XOR 
					data_in(412) XOR data_in(413) XOR data_in(414) XOR data_in(415) XOR data_in(416) XOR 
					data_in(417) XOR data_in(418) XOR data_in(419) XOR data_in(420) XOR data_in(421) XOR 
					data_in(422) XOR data_in(423) XOR data_in(424) XOR data_in(425) XOR data_in(426) XOR 
					data_in(427) XOR data_in(428) XOR data_in(429) XOR data_in(430) XOR data_in(431) XOR 
					data_in(432) XOR data_in(433) XOR data_in(434) XOR data_in(435) XOR data_in(436) XOR 
					data_in(437) XOR data_in(438) XOR data_in(439) XOR data_in(440) XOR data_in(441) XOR 
					data_in(442) XOR data_in(443) XOR data_in(444) XOR data_in(445) XOR data_in(446) XOR 
					data_in(447) XOR data_in(448) XOR data_in(449) XOR data_in(450) XOR data_in(451) XOR 
					data_in(452) XOR data_in(453) XOR data_in(454) XOR data_in(455) XOR data_in(456) XOR 
					data_in(457) XOR data_in(458) XOR data_in(459) XOR data_in(460) XOR data_in(461) XOR 
					data_in(462) XOR data_in(463) XOR data_in(464) XOR data_in(465) XOR data_in(466) XOR 
					data_in(467) XOR data_in(468) XOR data_in(469) XOR data_in(470) XOR data_in(471) XOR 
					data_in(472) XOR data_in(473) XOR data_in(474) XOR data_in(475) XOR data_in(476) XOR 
					data_in(477) XOR data_in(478) XOR data_in(479) XOR data_in(480) XOR data_in(481) XOR 
					data_in(482) XOR data_in(483) XOR data_in(484) XOR data_in(485) XOR data_in(486) XOR 
					data_in(487) XOR data_in(488) XOR data_in(489) XOR data_in(490) XOR data_in(491) XOR 
					data_in(492) XOR data_in(493) XOR data_in(494) XOR data_in(495);
   
	parity(7)	:=	data_in(57) XOR data_in(58) XOR data_in(59) XOR data_in(60) XOR data_in(61) XOR 
					data_in(62) XOR data_in(63) XOR data_in(64) XOR data_in(65) XOR data_in(66) XOR 
					data_in(67) XOR data_in(68) XOR data_in(69) XOR data_in(70) XOR data_in(71) XOR 
					data_in(72) XOR data_in(73) XOR data_in(74) XOR data_in(75) XOR data_in(76) XOR 
					data_in(77) XOR data_in(78) XOR data_in(79) XOR data_in(80) XOR data_in(81) XOR 
					data_in(82) XOR data_in(83) XOR data_in(84) XOR data_in(85) XOR data_in(86) XOR 
					data_in(87) XOR data_in(88) XOR data_in(89) XOR data_in(90) XOR data_in(91) XOR 
					data_in(92) XOR data_in(93) XOR data_in(94) XOR data_in(95) XOR data_in(96) XOR 
					data_in(97) XOR data_in(98) XOR data_in(99) XOR data_in(100) XOR data_in(101) XOR 
					data_in(102) XOR data_in(103) XOR data_in(104) XOR data_in(105) XOR data_in(106) XOR 
					data_in(107) XOR data_in(108) XOR data_in(109) XOR data_in(110) XOR data_in(111) XOR 
					data_in(112) XOR data_in(113) XOR data_in(114) XOR data_in(115) XOR data_in(116) XOR 
					data_in(117) XOR data_in(118) XOR data_in(119) XOR data_in(183) XOR data_in(184) XOR 
					data_in(185) XOR data_in(186) XOR data_in(187) XOR data_in(188) XOR data_in(189) XOR 
					data_in(190) XOR data_in(191) XOR data_in(192) XOR data_in(193) XOR data_in(194) XOR 
					data_in(195) XOR data_in(196) XOR data_in(197) XOR data_in(198) XOR data_in(199) XOR 
					data_in(200) XOR data_in(201) XOR data_in(202) XOR data_in(203) XOR data_in(204) XOR 
					data_in(205) XOR data_in(206) XOR data_in(207) XOR data_in(208) XOR data_in(209) XOR 
					data_in(210) XOR data_in(211) XOR data_in(212) XOR data_in(213) XOR data_in(214) XOR 
					data_in(215) XOR data_in(216) XOR data_in(217) XOR data_in(218) XOR data_in(219) XOR 
					data_in(220) XOR data_in(221) XOR data_in(222) XOR data_in(223) XOR data_in(224) XOR 
					data_in(225) XOR data_in(226) XOR data_in(227) XOR data_in(228) XOR data_in(229) XOR 
					data_in(230) XOR data_in(231) XOR data_in(232) XOR data_in(233) XOR data_in(234) XOR 
					data_in(235) XOR data_in(236) XOR data_in(237) XOR data_in(238) XOR data_in(239) XOR 
					data_in(240) XOR data_in(241) XOR data_in(242) XOR data_in(243) XOR data_in(244) XOR 
					data_in(245) XOR data_in(246) XOR data_in(310) XOR data_in(311) XOR data_in(312) XOR 
					data_in(313) XOR data_in(314) XOR data_in(315) XOR data_in(316) XOR data_in(317) XOR 
					data_in(318) XOR data_in(319) XOR data_in(320) XOR data_in(321) XOR data_in(322) XOR 
					data_in(323) XOR data_in(324) XOR data_in(325) XOR data_in(326) XOR data_in(327) XOR 
					data_in(328) XOR data_in(329) XOR data_in(330) XOR data_in(331) XOR data_in(332) XOR 
					data_in(333) XOR data_in(334) XOR data_in(335) XOR data_in(336) XOR data_in(337) XOR 
					data_in(338) XOR data_in(339) XOR data_in(340) XOR data_in(341) XOR data_in(342) XOR 
					data_in(343) XOR data_in(344) XOR data_in(345) XOR data_in(346) XOR data_in(347) XOR 
					data_in(348) XOR data_in(349) XOR data_in(350) XOR data_in(351) XOR data_in(352) XOR 
					data_in(353) XOR data_in(354) XOR data_in(355) XOR data_in(356) XOR data_in(357) XOR 
					data_in(358) XOR data_in(359) XOR data_in(360) XOR data_in(361) XOR data_in(362) XOR 
					data_in(363) XOR data_in(364) XOR data_in(365) XOR data_in(366) XOR data_in(367) XOR 
					data_in(368) XOR data_in(369) XOR data_in(370) XOR data_in(371) XOR data_in(372) XOR 
					data_in(373) XOR data_in(438) XOR data_in(439) XOR data_in(440) XOR data_in(441) XOR 
					data_in(442) XOR data_in(443) XOR data_in(444) XOR data_in(445) XOR data_in(446) XOR 
					data_in(447) XOR data_in(448) XOR data_in(449) XOR data_in(450) XOR data_in(451) XOR 
					data_in(452) XOR data_in(453) XOR data_in(454) XOR data_in(455) XOR data_in(456) XOR 
					data_in(457) XOR data_in(458) XOR data_in(459) XOR data_in(460) XOR data_in(461) XOR 
					data_in(462) XOR data_in(463) XOR data_in(464) XOR data_in(465) XOR data_in(466) XOR 
					data_in(467) XOR data_in(468) XOR data_in(469) XOR data_in(470) XOR data_in(471) XOR 
					data_in(472) XOR data_in(473) XOR data_in(474) XOR data_in(475) XOR data_in(476) XOR 
					data_in(477) XOR data_in(478) XOR data_in(479) XOR data_in(480) XOR data_in(481) XOR 
					data_in(482) XOR data_in(483) XOR data_in(484) XOR data_in(485) XOR data_in(486) XOR 
					data_in(487) XOR data_in(488) XOR data_in(489) XOR data_in(490) XOR data_in(491) XOR 
					data_in(492) XOR data_in(493) XOR data_in(494) XOR data_in(495);
   
	parity(6)	:=	data_in(26) XOR data_in(27) XOR data_in(28) XOR data_in(29) XOR data_in(30) XOR 
					data_in(31) XOR data_in(32) XOR data_in(33) XOR data_in(34) XOR data_in(35) XOR 
					data_in(36) XOR data_in(37) XOR data_in(38) XOR data_in(39) XOR data_in(40) XOR 
					data_in(41) XOR data_in(42) XOR data_in(43) XOR data_in(44) XOR data_in(45) XOR 
					data_in(46) XOR data_in(47) XOR data_in(48) XOR data_in(49) XOR data_in(50) XOR 
					data_in(51) XOR data_in(52) XOR data_in(53) XOR data_in(54) XOR data_in(55) XOR 
					data_in(56) XOR data_in(88) XOR data_in(89) XOR data_in(90) XOR data_in(91) XOR 
					data_in(92) XOR data_in(93) XOR data_in(94) XOR data_in(95) XOR data_in(96) XOR 
					data_in(97) XOR data_in(98) XOR data_in(99) XOR data_in(100) XOR data_in(101) XOR 
					data_in(102) XOR data_in(103) XOR data_in(104) XOR data_in(105) XOR data_in(106) XOR 
					data_in(107) XOR data_in(108) XOR data_in(109) XOR data_in(110) XOR data_in(111) XOR 
					data_in(112) XOR data_in(113) XOR data_in(114) XOR data_in(115) XOR data_in(116) XOR 
					data_in(117) XOR data_in(118) XOR data_in(119) XOR data_in(151) XOR data_in(152) XOR 
					data_in(153) XOR data_in(154) XOR data_in(155) XOR data_in(156) XOR data_in(157) XOR 
					data_in(158) XOR data_in(159) XOR data_in(160) XOR data_in(161) XOR data_in(162) XOR 
					data_in(163) XOR data_in(164) XOR data_in(165) XOR data_in(166) XOR data_in(167) XOR 
					data_in(168) XOR data_in(169) XOR data_in(170) XOR data_in(171) XOR data_in(172) XOR 
					data_in(173) XOR data_in(174) XOR data_in(175) XOR data_in(176) XOR data_in(177) XOR 
					data_in(178) XOR data_in(179) XOR data_in(180) XOR data_in(181) XOR data_in(182) XOR 
					data_in(215) XOR data_in(216) XOR data_in(217) XOR data_in(218) XOR data_in(219) XOR 
					data_in(220) XOR data_in(221) XOR data_in(222) XOR data_in(223) XOR data_in(224) XOR 
					data_in(225) XOR data_in(226) XOR data_in(227) XOR data_in(228) XOR data_in(229) XOR 
					data_in(230) XOR data_in(231) XOR data_in(232) XOR data_in(233) XOR data_in(234) XOR 
					data_in(235) XOR data_in(236) XOR data_in(237) XOR data_in(238) XOR data_in(239) XOR 
					data_in(240) XOR data_in(241) XOR data_in(242) XOR data_in(243) XOR data_in(244) XOR 
					data_in(245) XOR data_in(246) XOR data_in(278) XOR data_in(279) XOR data_in(280) XOR 
					data_in(281) XOR data_in(282) XOR data_in(283) XOR data_in(284) XOR data_in(285) XOR 
					data_in(286) XOR data_in(287) XOR data_in(288) XOR data_in(289) XOR data_in(290) XOR 
					data_in(291) XOR data_in(292) XOR data_in(293) XOR data_in(294) XOR data_in(295) XOR 
					data_in(296) XOR data_in(297) XOR data_in(298) XOR data_in(299) XOR data_in(300) XOR 
					data_in(301) XOR data_in(302) XOR data_in(303) XOR data_in(304) XOR data_in(305) XOR 
					data_in(306) XOR data_in(307) XOR data_in(308) XOR data_in(309) XOR data_in(342) XOR 
					data_in(343) XOR data_in(344) XOR data_in(345) XOR data_in(346) XOR data_in(347) XOR 
					data_in(348) XOR data_in(349) XOR data_in(350) XOR data_in(351) XOR data_in(352) XOR 
					data_in(353) XOR data_in(354) XOR data_in(355) XOR data_in(356) XOR data_in(357) XOR 
					data_in(358) XOR data_in(359) XOR data_in(360) XOR data_in(361) XOR data_in(362) XOR 
					data_in(363) XOR data_in(364) XOR data_in(365) XOR data_in(366) XOR data_in(367) XOR 
					data_in(368) XOR data_in(369) XOR data_in(370) XOR data_in(371) XOR data_in(372) XOR 
					data_in(373) XOR data_in(406) XOR data_in(407) XOR data_in(408) XOR data_in(409) XOR 
					data_in(410) XOR data_in(411) XOR data_in(412) XOR data_in(413) XOR data_in(414) XOR 
					data_in(415) XOR data_in(416) XOR data_in(417) XOR data_in(418) XOR data_in(419) XOR 
					data_in(420) XOR data_in(421) XOR data_in(422) XOR data_in(423) XOR data_in(424) XOR 
					data_in(425) XOR data_in(426) XOR data_in(427) XOR data_in(428) XOR data_in(429) XOR 
					data_in(430) XOR data_in(431) XOR data_in(432) XOR data_in(433) XOR data_in(434) XOR 
					data_in(435) XOR data_in(436) XOR data_in(437) XOR data_in(470) XOR data_in(471) XOR 
					data_in(472) XOR data_in(473) XOR data_in(474) XOR data_in(475) XOR data_in(476) XOR 
					data_in(477) XOR data_in(478) XOR data_in(479) XOR data_in(480) XOR data_in(481) XOR 
					data_in(482) XOR data_in(483) XOR data_in(484) XOR data_in(485) XOR data_in(486) XOR 
					data_in(487) XOR data_in(488) XOR data_in(489) XOR data_in(490) XOR data_in(491) XOR 
					data_in(492) XOR data_in(493) XOR data_in(494) XOR data_in(495);
   
	parity(5)	:=	data_in(11) XOR data_in(12) XOR data_in(13) XOR data_in(14) XOR data_in(15) XOR 
					data_in(16) XOR data_in(17) XOR data_in(18) XOR data_in(19) XOR data_in(20) XOR 
					data_in(21) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR data_in(25) XOR 
					data_in(41) XOR data_in(42) XOR data_in(43) XOR data_in(44) XOR data_in(45) XOR 
					data_in(46) XOR data_in(47) XOR data_in(48) XOR data_in(49) XOR data_in(50) XOR 
					data_in(51) XOR data_in(52) XOR data_in(53) XOR data_in(54) XOR data_in(55) XOR 
					data_in(56) XOR data_in(72) XOR data_in(73) XOR data_in(74) XOR data_in(75) XOR 
					data_in(76) XOR data_in(77) XOR data_in(78) XOR data_in(79) XOR data_in(80) XOR 
					data_in(81) XOR data_in(82) XOR data_in(83) XOR data_in(84) XOR data_in(85) XOR 
					data_in(86) XOR data_in(87) XOR data_in(104) XOR data_in(105) XOR data_in(106) XOR 
					data_in(107) XOR data_in(108) XOR data_in(109) XOR data_in(110) XOR data_in(111) XOR 
					data_in(112) XOR data_in(113) XOR data_in(114) XOR data_in(115) XOR data_in(116) XOR 
					data_in(117) XOR data_in(118) XOR data_in(119) XOR data_in(135) XOR data_in(136) XOR 
					data_in(137) XOR data_in(138) XOR data_in(139) XOR data_in(140) XOR data_in(141) XOR 
					data_in(142) XOR data_in(143) XOR data_in(144) XOR data_in(145) XOR data_in(146) XOR 
					data_in(147) XOR data_in(148) XOR data_in(149) XOR data_in(150) XOR data_in(167) XOR 
					data_in(168) XOR data_in(169) XOR data_in(170) XOR data_in(171) XOR data_in(172) XOR 
					data_in(173) XOR data_in(174) XOR data_in(175) XOR data_in(176) XOR data_in(177) XOR 
					data_in(178) XOR data_in(179) XOR data_in(180) XOR data_in(181) XOR data_in(182) XOR 
					data_in(199) XOR data_in(200) XOR data_in(201) XOR data_in(202) XOR data_in(203) XOR 
					data_in(204) XOR data_in(205) XOR data_in(206) XOR data_in(207) XOR data_in(208) XOR 
					data_in(209) XOR data_in(210) XOR data_in(211) XOR data_in(212) XOR data_in(213) XOR 
					data_in(214) XOR data_in(231) XOR data_in(232) XOR data_in(233) XOR data_in(234) XOR 
					data_in(235) XOR data_in(236) XOR data_in(237) XOR data_in(238) XOR data_in(239) XOR 
					data_in(240) XOR data_in(241) XOR data_in(242) XOR data_in(243) XOR data_in(244) XOR 
					data_in(245) XOR data_in(246) XOR data_in(262) XOR data_in(263) XOR data_in(264) XOR 
					data_in(265) XOR data_in(266) XOR data_in(267) XOR data_in(268) XOR data_in(269) XOR 
					data_in(270) XOR data_in(271) XOR data_in(272) XOR data_in(273) XOR data_in(274) XOR 
					data_in(275) XOR data_in(276) XOR data_in(277) XOR data_in(294) XOR data_in(295) XOR 
					data_in(296) XOR data_in(297) XOR data_in(298) XOR data_in(299) XOR data_in(300) XOR 
					data_in(301) XOR data_in(302) XOR data_in(303) XOR data_in(304) XOR data_in(305) XOR 
					data_in(306) XOR data_in(307) XOR data_in(308) XOR data_in(309) XOR data_in(326) XOR 
					data_in(327) XOR data_in(328) XOR data_in(329) XOR data_in(330) XOR data_in(331) XOR 
					data_in(332) XOR data_in(333) XOR data_in(334) XOR data_in(335) XOR data_in(336) XOR 
					data_in(337) XOR data_in(338) XOR data_in(339) XOR data_in(340) XOR data_in(341) XOR 
					data_in(358) XOR data_in(359) XOR data_in(360) XOR data_in(361) XOR data_in(362) XOR 
					data_in(363) XOR data_in(364) XOR data_in(365) XOR data_in(366) XOR data_in(367) XOR 
					data_in(368) XOR data_in(369) XOR data_in(370) XOR data_in(371) XOR data_in(372) XOR 
					data_in(373) XOR data_in(390) XOR data_in(391) XOR data_in(392) XOR data_in(393) XOR 
					data_in(394) XOR data_in(395) XOR data_in(396) XOR data_in(397) XOR data_in(398) XOR 
					data_in(399) XOR data_in(400) XOR data_in(401) XOR data_in(402) XOR data_in(403) XOR 
					data_in(404) XOR data_in(405) XOR data_in(422) XOR data_in(423) XOR data_in(424) XOR 
					data_in(425) XOR data_in(426) XOR data_in(427) XOR data_in(428) XOR data_in(429) XOR 
					data_in(430) XOR data_in(431) XOR data_in(432) XOR data_in(433) XOR data_in(434) XOR 
					data_in(435) XOR data_in(436) XOR data_in(437) XOR data_in(454) XOR data_in(455) XOR 
					data_in(456) XOR data_in(457) XOR data_in(458) XOR data_in(459) XOR data_in(460) XOR 
					data_in(461) XOR data_in(462) XOR data_in(463) XOR data_in(464) XOR data_in(465) XOR 
					data_in(466) XOR data_in(467) XOR data_in(468) XOR data_in(469) XOR data_in(486) XOR 
					data_in(487) XOR data_in(488) XOR data_in(489) XOR data_in(490) XOR data_in(491) XOR 
					data_in(492) XOR data_in(493) XOR data_in(494) XOR data_in(495);
   
	parity(4)	:=	data_in(4) XOR data_in(5) XOR data_in(6) XOR data_in(7) XOR data_in(8) XOR 
					data_in(9) XOR data_in(10) XOR data_in(18) XOR data_in(19) XOR data_in(20) XOR 
					data_in(21) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR data_in(25) XOR 
					data_in(33) XOR data_in(34) XOR data_in(35) XOR data_in(36) XOR data_in(37) XOR 
					data_in(38) XOR data_in(39) XOR data_in(40) XOR data_in(49) XOR data_in(50) XOR 
					data_in(51) XOR data_in(52) XOR data_in(53) XOR data_in(54) XOR data_in(55) XOR 
					data_in(56) XOR data_in(64) XOR data_in(65) XOR data_in(66) XOR data_in(67) XOR 
					data_in(68) XOR data_in(69) XOR data_in(70) XOR data_in(71) XOR data_in(80) XOR 
					data_in(81) XOR data_in(82) XOR data_in(83) XOR data_in(84) XOR data_in(85) XOR 
					data_in(86) XOR data_in(87) XOR data_in(96) XOR data_in(97) XOR data_in(98) XOR 
					data_in(99) XOR data_in(100) XOR data_in(101) XOR data_in(102) XOR data_in(103) XOR 
					data_in(112) XOR data_in(113) XOR data_in(114) XOR data_in(115) XOR data_in(116) XOR 
					data_in(117) XOR data_in(118) XOR data_in(119) XOR data_in(127) XOR data_in(128) XOR 
					data_in(129) XOR data_in(130) XOR data_in(131) XOR data_in(132) XOR data_in(133) XOR 
					data_in(134) XOR data_in(143) XOR data_in(144) XOR data_in(145) XOR data_in(146) XOR 
					data_in(147) XOR data_in(148) XOR data_in(149) XOR data_in(150) XOR data_in(159) XOR 
					data_in(160) XOR data_in(161) XOR data_in(162) XOR data_in(163) XOR data_in(164) XOR 
					data_in(165) XOR data_in(166) XOR data_in(175) XOR data_in(176) XOR data_in(177) XOR 
					data_in(178) XOR data_in(179) XOR data_in(180) XOR data_in(181) XOR data_in(182) XOR 
					data_in(191) XOR data_in(192) XOR data_in(193) XOR data_in(194) XOR data_in(195) XOR 
					data_in(196) XOR data_in(197) XOR data_in(198) XOR data_in(207) XOR data_in(208) XOR 
					data_in(209) XOR data_in(210) XOR data_in(211) XOR data_in(212) XOR data_in(213) XOR 
					data_in(214) XOR data_in(223) XOR data_in(224) XOR data_in(225) XOR data_in(226) XOR 
					data_in(227) XOR data_in(228) XOR data_in(229) XOR data_in(230) XOR data_in(239) XOR 
					data_in(240) XOR data_in(241) XOR data_in(242) XOR data_in(243) XOR data_in(244) XOR 
					data_in(245) XOR data_in(246) XOR data_in(254) XOR data_in(255) XOR data_in(256) XOR 
					data_in(257) XOR data_in(258) XOR data_in(259) XOR data_in(260) XOR data_in(261) XOR 
					data_in(270) XOR data_in(271) XOR data_in(272) XOR data_in(273) XOR data_in(274) XOR 
					data_in(275) XOR data_in(276) XOR data_in(277) XOR data_in(286) XOR data_in(287) XOR 
					data_in(288) XOR data_in(289) XOR data_in(290) XOR data_in(291) XOR data_in(292) XOR 
					data_in(293) XOR data_in(302) XOR data_in(303) XOR data_in(304) XOR data_in(305) XOR 
					data_in(306) XOR data_in(307) XOR data_in(308) XOR data_in(309) XOR data_in(318) XOR 
					data_in(319) XOR data_in(320) XOR data_in(321) XOR data_in(322) XOR data_in(323) XOR 
					data_in(324) XOR data_in(325) XOR data_in(334) XOR data_in(335) XOR data_in(336) XOR 
					data_in(337) XOR data_in(338) XOR data_in(339) XOR data_in(340) XOR data_in(341) XOR 
					data_in(350) XOR data_in(351) XOR data_in(352) XOR data_in(353) XOR data_in(354) XOR 
					data_in(355) XOR data_in(356) XOR data_in(357) XOR data_in(366) XOR data_in(367) XOR 
					data_in(368) XOR data_in(369) XOR data_in(370) XOR data_in(371) XOR data_in(372) XOR 
					data_in(373) XOR data_in(382) XOR data_in(383) XOR data_in(384) XOR data_in(385) XOR 
					data_in(386) XOR data_in(387) XOR data_in(388) XOR data_in(389) XOR data_in(398) XOR 
					data_in(399) XOR data_in(400) XOR data_in(401) XOR data_in(402) XOR data_in(403) XOR 
					data_in(404) XOR data_in(405) XOR data_in(414) XOR data_in(415) XOR data_in(416) XOR 
					data_in(417) XOR data_in(418) XOR data_in(419) XOR data_in(420) XOR data_in(421) XOR 
					data_in(430) XOR data_in(431) XOR data_in(432) XOR data_in(433) XOR data_in(434) XOR 
					data_in(435) XOR data_in(436) XOR data_in(437) XOR data_in(446) XOR data_in(447) XOR 
					data_in(448) XOR data_in(449) XOR data_in(450) XOR data_in(451) XOR data_in(452) XOR 
					data_in(453) XOR data_in(462) XOR data_in(463) XOR data_in(464) XOR data_in(465) XOR 
					data_in(466) XOR data_in(467) XOR data_in(468) XOR data_in(469) XOR data_in(478) XOR 
					data_in(479) XOR data_in(480) XOR data_in(481) XOR data_in(482) XOR data_in(483) XOR 
					data_in(484) XOR data_in(485) XOR data_in(494) XOR data_in(495);
   
	parity(3)	:=	data_in(1) XOR data_in(2) XOR data_in(3) XOR data_in(7) XOR data_in(8) XOR 
					data_in(9) XOR data_in(10) XOR data_in(14) XOR data_in(15) XOR data_in(16) XOR 
					data_in(17) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR data_in(25) XOR 
					data_in(29) XOR data_in(30) XOR data_in(31) XOR data_in(32) XOR data_in(37) XOR 
					data_in(38) XOR data_in(39) XOR data_in(40) XOR data_in(45) XOR data_in(46) XOR 
					data_in(47) XOR data_in(48) XOR data_in(53) XOR data_in(54) XOR data_in(55) XOR 
					data_in(56) XOR data_in(60) XOR data_in(61) XOR data_in(62) XOR data_in(63) XOR 
					data_in(68) XOR data_in(69) XOR data_in(70) XOR data_in(71) XOR data_in(76) XOR 
					data_in(77) XOR data_in(78) XOR data_in(79) XOR data_in(84) XOR data_in(85) XOR 
					data_in(86) XOR data_in(87) XOR data_in(92) XOR data_in(93) XOR data_in(94) XOR 
					data_in(95) XOR data_in(100) XOR data_in(101) XOR data_in(102) XOR data_in(103) XOR 
					data_in(108) XOR data_in(109) XOR data_in(110) XOR data_in(111) XOR data_in(116) XOR 
					data_in(117) XOR data_in(118) XOR data_in(119) XOR data_in(123) XOR data_in(124) XOR 
					data_in(125) XOR data_in(126) XOR data_in(131) XOR data_in(132) XOR data_in(133) XOR 
					data_in(134) XOR data_in(139) XOR data_in(140) XOR data_in(141) XOR data_in(142) XOR 
					data_in(147) XOR data_in(148) XOR data_in(149) XOR data_in(150) XOR data_in(155) XOR 
					data_in(156) XOR data_in(157) XOR data_in(158) XOR data_in(163) XOR data_in(164) XOR 
					data_in(165) XOR data_in(166) XOR data_in(171) XOR data_in(172) XOR data_in(173) XOR 
					data_in(174) XOR data_in(179) XOR data_in(180) XOR data_in(181) XOR data_in(182) XOR 
					data_in(187) XOR data_in(188) XOR data_in(189) XOR data_in(190) XOR data_in(195) XOR 
					data_in(196) XOR data_in(197) XOR data_in(198) XOR data_in(203) XOR data_in(204) XOR 
					data_in(205) XOR data_in(206) XOR data_in(211) XOR data_in(212) XOR data_in(213) XOR 
					data_in(214) XOR data_in(219) XOR data_in(220) XOR data_in(221) XOR data_in(222) XOR 
					data_in(227) XOR data_in(228) XOR data_in(229) XOR data_in(230) XOR data_in(235) XOR 
					data_in(236) XOR data_in(237) XOR data_in(238) XOR data_in(243) XOR data_in(244) XOR 
					data_in(245) XOR data_in(246) XOR data_in(250) XOR data_in(251) XOR data_in(252) XOR 
					data_in(253) XOR data_in(258) XOR data_in(259) XOR data_in(260) XOR data_in(261) XOR 
					data_in(266) XOR data_in(267) XOR data_in(268) XOR data_in(269) XOR data_in(274) XOR 
					data_in(275) XOR data_in(276) XOR data_in(277) XOR data_in(282) XOR data_in(283) XOR 
					data_in(284) XOR data_in(285) XOR data_in(290) XOR data_in(291) XOR data_in(292) XOR 
					data_in(293) XOR data_in(298) XOR data_in(299) XOR data_in(300) XOR data_in(301) XOR 
					data_in(306) XOR data_in(307) XOR data_in(308) XOR data_in(309) XOR data_in(314) XOR 
					data_in(315) XOR data_in(316) XOR data_in(317) XOR data_in(322) XOR data_in(323) XOR 
					data_in(324) XOR data_in(325) XOR data_in(330) XOR data_in(331) XOR data_in(332) XOR 
					data_in(333) XOR data_in(338) XOR data_in(339) XOR data_in(340) XOR data_in(341) XOR 
					data_in(346) XOR data_in(347) XOR data_in(348) XOR data_in(349) XOR data_in(354) XOR 
					data_in(355) XOR data_in(356) XOR data_in(357) XOR data_in(362) XOR data_in(363) XOR 
					data_in(364) XOR data_in(365) XOR data_in(370) XOR data_in(371) XOR data_in(372) XOR 
					data_in(373) XOR data_in(378) XOR data_in(379) XOR data_in(380) XOR data_in(381) XOR 
					data_in(386) XOR data_in(387) XOR data_in(388) XOR data_in(389) XOR data_in(394) XOR 
					data_in(395) XOR data_in(396) XOR data_in(397) XOR data_in(402) XOR data_in(403) XOR 
					data_in(404) XOR data_in(405) XOR data_in(410) XOR data_in(411) XOR data_in(412) XOR 
					data_in(413) XOR data_in(418) XOR data_in(419) XOR data_in(420) XOR data_in(421) XOR 
					data_in(426) XOR data_in(427) XOR data_in(428) XOR data_in(429) XOR data_in(434) XOR 
					data_in(435) XOR data_in(436) XOR data_in(437) XOR data_in(442) XOR data_in(443) XOR 
					data_in(444) XOR data_in(445) XOR data_in(450) XOR data_in(451) XOR data_in(452) XOR 
					data_in(453) XOR data_in(458) XOR data_in(459) XOR data_in(460) XOR data_in(461) XOR 
					data_in(466) XOR data_in(467) XOR data_in(468) XOR data_in(469) XOR data_in(474) XOR 
					data_in(475) XOR data_in(476) XOR data_in(477) XOR data_in(482) XOR data_in(483) XOR 
					data_in(484) XOR data_in(485) XOR data_in(490) XOR data_in(491) XOR data_in(492) XOR 
					data_in(493);
   
	parity(2)	:=	data_in(0) XOR data_in(2) XOR data_in(3) XOR data_in(5) XOR data_in(6) XOR 
					data_in(9) XOR data_in(10) XOR data_in(12) XOR data_in(13) XOR data_in(16) XOR 
					data_in(17) XOR data_in(20) XOR data_in(21) XOR data_in(24) XOR data_in(25) XOR 
					data_in(27) XOR data_in(28) XOR data_in(31) XOR data_in(32) XOR data_in(35) XOR 
					data_in(36) XOR data_in(39) XOR data_in(40) XOR data_in(43) XOR data_in(44) XOR 
					data_in(47) XOR data_in(48) XOR data_in(51) XOR data_in(52) XOR data_in(55) XOR 
					data_in(56) XOR data_in(58) XOR data_in(59) XOR data_in(62) XOR data_in(63) XOR 
					data_in(66) XOR data_in(67) XOR data_in(70) XOR data_in(71) XOR data_in(74) XOR 
					data_in(75) XOR data_in(78) XOR data_in(79) XOR data_in(82) XOR data_in(83) XOR 
					data_in(86) XOR data_in(87) XOR data_in(90) XOR data_in(91) XOR data_in(94) XOR 
					data_in(95) XOR data_in(98) XOR data_in(99) XOR data_in(102) XOR data_in(103) XOR 
					data_in(106) XOR data_in(107) XOR data_in(110) XOR data_in(111) XOR data_in(114) XOR 
					data_in(115) XOR data_in(118) XOR data_in(119) XOR data_in(121) XOR data_in(122) XOR 
					data_in(125) XOR data_in(126) XOR data_in(129) XOR data_in(130) XOR data_in(133) XOR 
					data_in(134) XOR data_in(137) XOR data_in(138) XOR data_in(141) XOR data_in(142) XOR 
					data_in(145) XOR data_in(146) XOR data_in(149) XOR data_in(150) XOR data_in(153) XOR 
					data_in(154) XOR data_in(157) XOR data_in(158) XOR data_in(161) XOR data_in(162) XOR 
					data_in(165) XOR data_in(166) XOR data_in(169) XOR data_in(170) XOR data_in(173) XOR 
					data_in(174) XOR data_in(177) XOR data_in(178) XOR data_in(181) XOR data_in(182) XOR 
					data_in(185) XOR data_in(186) XOR data_in(189) XOR data_in(190) XOR data_in(193) XOR 
					data_in(194) XOR data_in(197) XOR data_in(198) XOR data_in(201) XOR data_in(202) XOR 
					data_in(205) XOR data_in(206) XOR data_in(209) XOR data_in(210) XOR data_in(213) XOR 
					data_in(214) XOR data_in(217) XOR data_in(218) XOR data_in(221) XOR data_in(222) XOR 
					data_in(225) XOR data_in(226) XOR data_in(229) XOR data_in(230) XOR data_in(233) XOR 
					data_in(234) XOR data_in(237) XOR data_in(238) XOR data_in(241) XOR data_in(242) XOR 
					data_in(245) XOR data_in(246) XOR data_in(248) XOR data_in(249) XOR data_in(252) XOR 
					data_in(253) XOR data_in(256) XOR data_in(257) XOR data_in(260) XOR data_in(261) XOR 
					data_in(264) XOR data_in(265) XOR data_in(268) XOR data_in(269) XOR data_in(272) XOR 
					data_in(273) XOR data_in(276) XOR data_in(277) XOR data_in(280) XOR data_in(281) XOR 
					data_in(284) XOR data_in(285) XOR data_in(288) XOR data_in(289) XOR data_in(292) XOR 
					data_in(293) XOR data_in(296) XOR data_in(297) XOR data_in(300) XOR data_in(301) XOR 
					data_in(304) XOR data_in(305) XOR data_in(308) XOR data_in(309) XOR data_in(312) XOR 
					data_in(313) XOR data_in(316) XOR data_in(317) XOR data_in(320) XOR data_in(321) XOR 
					data_in(324) XOR data_in(325) XOR data_in(328) XOR data_in(329) XOR data_in(332) XOR 
					data_in(333) XOR data_in(336) XOR data_in(337) XOR data_in(340) XOR data_in(341) XOR 
					data_in(344) XOR data_in(345) XOR data_in(348) XOR data_in(349) XOR data_in(352) XOR 
					data_in(353) XOR data_in(356) XOR data_in(357) XOR data_in(360) XOR data_in(361) XOR 
					data_in(364) XOR data_in(365) XOR data_in(368) XOR data_in(369) XOR data_in(372) XOR 
					data_in(373) XOR data_in(376) XOR data_in(377) XOR data_in(380) XOR data_in(381) XOR 
					data_in(384) XOR data_in(385) XOR data_in(388) XOR data_in(389) XOR data_in(392) XOR 
					data_in(393) XOR data_in(396) XOR data_in(397) XOR data_in(400) XOR data_in(401) XOR 
					data_in(404) XOR data_in(405) XOR data_in(408) XOR data_in(409) XOR data_in(412) XOR 
					data_in(413) XOR data_in(416) XOR data_in(417) XOR data_in(420) XOR data_in(421) XOR 
					data_in(424) XOR data_in(425) XOR data_in(428) XOR data_in(429) XOR data_in(432) XOR 
					data_in(433) XOR data_in(436) XOR data_in(437) XOR data_in(440) XOR data_in(441) XOR 
					data_in(444) XOR data_in(445) XOR data_in(448) XOR data_in(449) XOR data_in(452) XOR 
					data_in(453) XOR data_in(456) XOR data_in(457) XOR data_in(460) XOR data_in(461) XOR 
					data_in(464) XOR data_in(465) XOR data_in(468) XOR data_in(469) XOR data_in(472) XOR 
					data_in(473) XOR data_in(476) XOR data_in(477) XOR data_in(480) XOR data_in(481) XOR 
					data_in(484) XOR data_in(485) XOR data_in(488) XOR data_in(489) XOR data_in(492) XOR 
					data_in(493);
   
	parity(1)	:=	data_in(0) XOR data_in(1) XOR data_in(3) XOR data_in(4) XOR data_in(6) XOR 
					data_in(8) XOR data_in(10) XOR data_in(11) XOR data_in(13) XOR data_in(15) XOR 
					data_in(17) XOR data_in(19) XOR data_in(21) XOR data_in(23) XOR data_in(25) XOR 
					data_in(26) XOR data_in(28) XOR data_in(30) XOR data_in(32) XOR data_in(34) XOR 
					data_in(36) XOR data_in(38) XOR data_in(40) XOR data_in(42) XOR data_in(44) XOR 
					data_in(46) XOR data_in(48) XOR data_in(50) XOR data_in(52) XOR data_in(54) XOR 
					data_in(56) XOR data_in(57) XOR data_in(59) XOR data_in(61) XOR data_in(63) XOR 
					data_in(65) XOR data_in(67) XOR data_in(69) XOR data_in(71) XOR data_in(73) XOR 
					data_in(75) XOR data_in(77) XOR data_in(79) XOR data_in(81) XOR data_in(83) XOR 
					data_in(85) XOR data_in(87) XOR data_in(89) XOR data_in(91) XOR data_in(93) XOR 
					data_in(95) XOR data_in(97) XOR data_in(99) XOR data_in(101) XOR data_in(103) XOR 
					data_in(105) XOR data_in(107) XOR data_in(109) XOR data_in(111) XOR data_in(113) XOR 
					data_in(115) XOR data_in(117) XOR data_in(119) XOR data_in(120) XOR data_in(122) XOR 
					data_in(124) XOR data_in(126) XOR data_in(128) XOR data_in(130) XOR data_in(132) XOR 
					data_in(134) XOR data_in(136) XOR data_in(138) XOR data_in(140) XOR data_in(142) XOR 
					data_in(144) XOR data_in(146) XOR data_in(148) XOR data_in(150) XOR data_in(152) XOR 
					data_in(154) XOR data_in(156) XOR data_in(158) XOR data_in(160) XOR data_in(162) XOR 
					data_in(164) XOR data_in(166) XOR data_in(168) XOR data_in(170) XOR data_in(172) XOR 
					data_in(174) XOR data_in(176) XOR data_in(178) XOR data_in(180) XOR data_in(182) XOR 
					data_in(184) XOR data_in(186) XOR data_in(188) XOR data_in(190) XOR data_in(192) XOR 
					data_in(194) XOR data_in(196) XOR data_in(198) XOR data_in(200) XOR data_in(202) XOR 
					data_in(204) XOR data_in(206) XOR data_in(208) XOR data_in(210) XOR data_in(212) XOR 
					data_in(214) XOR data_in(216) XOR data_in(218) XOR data_in(220) XOR data_in(222) XOR 
					data_in(224) XOR data_in(226) XOR data_in(228) XOR data_in(230) XOR data_in(232) XOR 
					data_in(234) XOR data_in(236) XOR data_in(238) XOR data_in(240) XOR data_in(242) XOR 
					data_in(244) XOR data_in(246) XOR data_in(247) XOR data_in(249) XOR data_in(251) XOR 
					data_in(253) XOR data_in(255) XOR data_in(257) XOR data_in(259) XOR data_in(261) XOR 
					data_in(263) XOR data_in(265) XOR data_in(267) XOR data_in(269) XOR data_in(271) XOR 
					data_in(273) XOR data_in(275) XOR data_in(277) XOR data_in(279) XOR data_in(281) XOR 
					data_in(283) XOR data_in(285) XOR data_in(287) XOR data_in(289) XOR data_in(291) XOR 
					data_in(293) XOR data_in(295) XOR data_in(297) XOR data_in(299) XOR data_in(301) XOR 
					data_in(303) XOR data_in(305) XOR data_in(307) XOR data_in(309) XOR data_in(311) XOR 
					data_in(313) XOR data_in(315) XOR data_in(317) XOR data_in(319) XOR data_in(321) XOR 
					data_in(323) XOR data_in(325) XOR data_in(327) XOR data_in(329) XOR data_in(331) XOR 
					data_in(333) XOR data_in(335) XOR data_in(337) XOR data_in(339) XOR data_in(341) XOR 
					data_in(343) XOR data_in(345) XOR data_in(347) XOR data_in(349) XOR data_in(351) XOR 
					data_in(353) XOR data_in(355) XOR data_in(357) XOR data_in(359) XOR data_in(361) XOR 
					data_in(363) XOR data_in(365) XOR data_in(367) XOR data_in(369) XOR data_in(371) XOR 
					data_in(373) XOR data_in(375) XOR data_in(377) XOR data_in(379) XOR data_in(381) XOR 
					data_in(383) XOR data_in(385) XOR data_in(387) XOR data_in(389) XOR data_in(391) XOR 
					data_in(393) XOR data_in(395) XOR data_in(397) XOR data_in(399) XOR data_in(401) XOR 
					data_in(403) XOR data_in(405) XOR data_in(407) XOR data_in(409) XOR data_in(411) XOR 
					data_in(413) XOR data_in(415) XOR data_in(417) XOR data_in(419) XOR data_in(421) XOR 
					data_in(423) XOR data_in(425) XOR data_in(427) XOR data_in(429) XOR data_in(431) XOR 
					data_in(433) XOR data_in(435) XOR data_in(437) XOR data_in(439) XOR data_in(441) XOR 
					data_in(443) XOR data_in(445) XOR data_in(447) XOR data_in(449) XOR data_in(451) XOR 
					data_in(453) XOR data_in(455) XOR data_in(457) XOR data_in(459) XOR data_in(461) XOR 
					data_in(463) XOR data_in(465) XOR data_in(467) XOR data_in(469) XOR data_in(471) XOR 
					data_in(473) XOR data_in(475) XOR data_in(477) XOR data_in(479) XOR data_in(481) XOR 
					data_in(483) XOR data_in(485) XOR data_in(487) XOR data_in(489) XOR data_in(491) XOR 
					data_in(493) XOR data_in(495);
   
	parity(0)	:=	data_in(0) XOR data_in(1) XOR data_in(2) XOR data_in(3) XOR data_in(4) XOR 
					data_in(5) XOR data_in(6) XOR data_in(7) XOR data_in(8) XOR data_in(9) XOR 
					data_in(10) XOR data_in(11) XOR data_in(12) XOR data_in(13) XOR data_in(14) XOR 
					data_in(15) XOR data_in(16) XOR data_in(17) XOR data_in(18) XOR data_in(19) XOR 
					data_in(20) XOR data_in(21) XOR data_in(22) XOR data_in(23) XOR data_in(24) XOR 
					data_in(25) XOR data_in(26) XOR data_in(27) XOR data_in(28) XOR data_in(29) XOR 
					data_in(30) XOR data_in(31) XOR data_in(32) XOR data_in(33) XOR data_in(34) XOR 
					data_in(35) XOR data_in(36) XOR data_in(37) XOR data_in(38) XOR data_in(39) XOR 
					data_in(40) XOR data_in(41) XOR data_in(42) XOR data_in(43) XOR data_in(44) XOR 
					data_in(45) XOR data_in(46) XOR data_in(47) XOR data_in(48) XOR data_in(49) XOR 
					data_in(50) XOR data_in(51) XOR data_in(52) XOR data_in(53) XOR data_in(54) XOR 
					data_in(55) XOR data_in(56) XOR data_in(57) XOR data_in(58) XOR data_in(59) XOR 
					data_in(60) XOR data_in(61) XOR data_in(62) XOR data_in(63) XOR data_in(64) XOR 
					data_in(65) XOR data_in(66) XOR data_in(67) XOR data_in(68) XOR data_in(69) XOR 
					data_in(70) XOR data_in(71) XOR data_in(72) XOR data_in(73) XOR data_in(74) XOR 
					data_in(75) XOR data_in(76) XOR data_in(77) XOR data_in(78) XOR data_in(79) XOR 
					data_in(80) XOR data_in(81) XOR data_in(82) XOR data_in(83) XOR data_in(84) XOR 
					data_in(85) XOR data_in(86) XOR data_in(87) XOR data_in(88) XOR data_in(89) XOR 
					data_in(90) XOR data_in(91) XOR data_in(92) XOR data_in(93) XOR data_in(94) XOR 
					data_in(95) XOR data_in(96) XOR data_in(97) XOR data_in(98) XOR data_in(99) XOR 
					data_in(100) XOR data_in(101) XOR data_in(102) XOR data_in(103) XOR data_in(104) XOR 
					data_in(105) XOR data_in(106) XOR data_in(107) XOR data_in(108) XOR data_in(109) XOR 
					data_in(110) XOR data_in(111) XOR data_in(112) XOR data_in(113) XOR data_in(114) XOR 
					data_in(115) XOR data_in(116) XOR data_in(117) XOR data_in(118) XOR data_in(119) XOR 
					data_in(120) XOR data_in(121) XOR data_in(122) XOR data_in(123) XOR data_in(124) XOR 
					data_in(125) XOR data_in(126) XOR data_in(127) XOR data_in(128) XOR data_in(129) XOR 
					data_in(130) XOR data_in(131) XOR data_in(132) XOR data_in(133) XOR data_in(134) XOR 
					data_in(135) XOR data_in(136) XOR data_in(137) XOR data_in(138) XOR data_in(139) XOR 
					data_in(140) XOR data_in(141) XOR data_in(142) XOR data_in(143) XOR data_in(144) XOR 
					data_in(145) XOR data_in(146) XOR data_in(147) XOR data_in(148) XOR data_in(149) XOR 
					data_in(150) XOR data_in(151) XOR data_in(152) XOR data_in(153) XOR data_in(154) XOR 
					data_in(155) XOR data_in(156) XOR data_in(157) XOR data_in(158) XOR data_in(159) XOR 
					data_in(160) XOR data_in(161) XOR data_in(162) XOR data_in(163) XOR data_in(164) XOR 
					data_in(165) XOR data_in(166) XOR data_in(167) XOR data_in(168) XOR data_in(169) XOR 
					data_in(170) XOR data_in(171) XOR data_in(172) XOR data_in(173) XOR data_in(174) XOR 
					data_in(175) XOR data_in(176) XOR data_in(177) XOR data_in(178) XOR data_in(179) XOR 
					data_in(180) XOR data_in(181) XOR data_in(182) XOR data_in(183) XOR data_in(184) XOR 
					data_in(185) XOR data_in(186) XOR data_in(187) XOR data_in(188) XOR data_in(189) XOR 
					data_in(190) XOR data_in(191) XOR data_in(192) XOR data_in(193) XOR data_in(194) XOR 
					data_in(195) XOR data_in(196) XOR data_in(197) XOR data_in(198) XOR data_in(199) XOR 
					data_in(200) XOR data_in(201) XOR data_in(202) XOR data_in(203) XOR data_in(204) XOR 
					data_in(205) XOR data_in(206) XOR data_in(207) XOR data_in(208) XOR data_in(209) XOR 
					data_in(210) XOR data_in(211) XOR data_in(212) XOR data_in(213) XOR data_in(214) XOR 
					data_in(215) XOR data_in(216) XOR data_in(217) XOR data_in(218) XOR data_in(219) XOR 
					data_in(220) XOR data_in(221) XOR data_in(222) XOR data_in(223) XOR data_in(224) XOR 
					data_in(225) XOR data_in(226) XOR data_in(227) XOR data_in(228) XOR data_in(229) XOR 
					data_in(230) XOR data_in(231) XOR data_in(232) XOR data_in(233) XOR data_in(234) XOR 
					data_in(235) XOR data_in(236) XOR data_in(237) XOR data_in(238) XOR data_in(239) XOR 
					data_in(240) XOR data_in(241) XOR data_in(242) XOR data_in(243) XOR data_in(244) XOR 
					data_in(245) XOR data_in(246) XOR data_in(247) XOR data_in(248) XOR data_in(249) XOR 
					data_in(250) XOR data_in(251) XOR data_in(252) XOR data_in(253) XOR data_in(254) XOR 
					data_in(255) XOR data_in(256) XOR data_in(257) XOR data_in(258) XOR data_in(259) XOR 
					data_in(260) XOR data_in(261) XOR data_in(262) XOR data_in(263) XOR data_in(264) XOR 
					data_in(265) XOR data_in(266) XOR data_in(267) XOR data_in(268) XOR data_in(269) XOR 
					data_in(270) XOR data_in(271) XOR data_in(272) XOR data_in(273) XOR data_in(274) XOR 
					data_in(275) XOR data_in(276) XOR data_in(277) XOR data_in(278) XOR data_in(279) XOR 
					data_in(280) XOR data_in(281) XOR data_in(282) XOR data_in(283) XOR data_in(284) XOR 
					data_in(285) XOR data_in(286) XOR data_in(287) XOR data_in(288) XOR data_in(289) XOR 
					data_in(290) XOR data_in(291) XOR data_in(292) XOR data_in(293) XOR data_in(294) XOR 
					data_in(295) XOR data_in(296) XOR data_in(297) XOR data_in(298) XOR data_in(299) XOR 
					data_in(300) XOR data_in(301) XOR data_in(302) XOR data_in(303) XOR data_in(304) XOR 
					data_in(305) XOR data_in(306) XOR data_in(307) XOR data_in(308) XOR data_in(309) XOR 
					data_in(310) XOR data_in(311) XOR data_in(312) XOR data_in(313) XOR data_in(314) XOR 
					data_in(315) XOR data_in(316) XOR data_in(317) XOR data_in(318) XOR data_in(319) XOR 
					data_in(320) XOR data_in(321) XOR data_in(322) XOR data_in(323) XOR data_in(324) XOR 
					data_in(325) XOR data_in(326) XOR data_in(327) XOR data_in(328) XOR data_in(329) XOR 
					data_in(330) XOR data_in(331) XOR data_in(332) XOR data_in(333) XOR data_in(334) XOR 
					data_in(335) XOR data_in(336) XOR data_in(337) XOR data_in(338) XOR data_in(339) XOR 
					data_in(340) XOR data_in(341) XOR data_in(342) XOR data_in(343) XOR data_in(344) XOR 
					data_in(345) XOR data_in(346) XOR data_in(347) XOR data_in(348) XOR data_in(349) XOR 
					data_in(350) XOR data_in(351) XOR data_in(352) XOR data_in(353) XOR data_in(354) XOR 
					data_in(355) XOR data_in(356) XOR data_in(357) XOR data_in(358) XOR data_in(359) XOR 
					data_in(360) XOR data_in(361) XOR data_in(362) XOR data_in(363) XOR data_in(364) XOR 
					data_in(365) XOR data_in(366) XOR data_in(367) XOR data_in(368) XOR data_in(369) XOR 
					data_in(370) XOR data_in(371) XOR data_in(372) XOR data_in(373) XOR data_in(374) XOR 
					data_in(375) XOR data_in(376) XOR data_in(377) XOR data_in(378) XOR data_in(379) XOR 
					data_in(380) XOR data_in(381) XOR data_in(382) XOR data_in(383) XOR data_in(384) XOR 
					data_in(385) XOR data_in(386) XOR data_in(387) XOR data_in(388) XOR data_in(389) XOR 
					data_in(390) XOR data_in(391) XOR data_in(392) XOR data_in(393) XOR data_in(394) XOR 
					data_in(395) XOR data_in(396) XOR data_in(397) XOR data_in(398) XOR data_in(399) XOR 
					data_in(400) XOR data_in(401) XOR data_in(402) XOR data_in(403) XOR data_in(404) XOR 
					data_in(405) XOR data_in(406) XOR data_in(407) XOR data_in(408) XOR data_in(409) XOR 
					data_in(410) XOR data_in(411) XOR data_in(412) XOR data_in(413) XOR data_in(414) XOR 
					data_in(415) XOR data_in(416) XOR data_in(417) XOR data_in(418) XOR data_in(419) XOR 
					data_in(420) XOR data_in(421) XOR data_in(422) XOR data_in(423) XOR data_in(424) XOR 
					data_in(425) XOR data_in(426) XOR data_in(427) XOR data_in(428) XOR data_in(429) XOR 
					data_in(430) XOR data_in(431) XOR data_in(432) XOR data_in(433) XOR data_in(434) XOR 
					data_in(435) XOR data_in(436) XOR data_in(437) XOR data_in(438) XOR data_in(439) XOR 
					data_in(440) XOR data_in(441) XOR data_in(442) XOR data_in(443) XOR data_in(444) XOR 
					data_in(445) XOR data_in(446) XOR data_in(447) XOR data_in(448) XOR data_in(449) XOR 
					data_in(450) XOR data_in(451) XOR data_in(452) XOR data_in(453) XOR data_in(454) XOR 
					data_in(455) XOR data_in(456) XOR data_in(457) XOR data_in(458) XOR data_in(459) XOR 
					data_in(460) XOR data_in(461) XOR data_in(462) XOR data_in(463) XOR data_in(464) XOR 
					data_in(465) XOR data_in(466) XOR data_in(467) XOR data_in(468) XOR data_in(469) XOR 
					data_in(470) XOR data_in(471) XOR data_in(472) XOR data_in(473) XOR data_in(474) XOR 
					data_in(475) XOR data_in(476) XOR data_in(477) XOR data_in(478) XOR data_in(479) XOR 
					data_in(480) XOR data_in(481) XOR data_in(482) XOR data_in(483) XOR data_in(484) XOR 
					data_in(485) XOR data_in(486) XOR data_in(487) XOR data_in(488) XOR data_in(489) XOR 
					data_in(490) XOR data_in(491) XOR data_in(492) XOR data_in(493) XOR data_in(494) XOR 
					data_in(495) XOR parity(1) XOR parity(2) XOR parity(3) XOR parity(4) XOR 
					parity(5) XOR parity(6) XOR parity(7) XOR parity(8) XOR parity(9) 
					;

	coded(0)	:=	data_parity_in(0);
	coded(1)	:=	data_parity_in(1);
	coded(2)	:=	data_parity_in(2);
	coded(4)	:=	data_parity_in(3);
	coded(8)	:=	data_parity_in(4);
	coded(16)	:=	data_parity_in(5);
	coded(32)	:=	data_parity_in(6);
	coded(64)	:=	data_parity_in(7);
	coded(128)	:=	data_parity_in(8);
	coded(256)	:=	data_parity_in(9);
	coded(3)	:=	data_parity_in(10);
	coded(5)	:=	data_parity_in(11);
	coded(6)	:=	data_parity_in(12);
	coded(7)	:=	data_parity_in(13);
	coded(9)	:=	data_parity_in(14);
	coded(10)	:=	data_parity_in(15);
	coded(11)	:=	data_parity_in(16);
	coded(12)	:=	data_parity_in(17);
	coded(13)	:=	data_parity_in(18);
	coded(14)	:=	data_parity_in(19);
	coded(15)	:=	data_parity_in(20);
	coded(17)	:=	data_parity_in(21);
	coded(18)	:=	data_parity_in(22);
	coded(19)	:=	data_parity_in(23);
	coded(20)	:=	data_parity_in(24);
	coded(21)	:=	data_parity_in(25);
	coded(22)	:=	data_parity_in(26);
	coded(23)	:=	data_parity_in(27);
	coded(24)	:=	data_parity_in(28);
	coded(25)	:=	data_parity_in(29);
	coded(26)	:=	data_parity_in(30);
	coded(27)	:=	data_parity_in(31);
	coded(28)	:=	data_parity_in(32);
	coded(29)	:=	data_parity_in(33);
	coded(30)	:=	data_parity_in(34);
	coded(31)	:=	data_parity_in(35);
	coded(33)	:=	data_parity_in(36);
	coded(34)	:=	data_parity_in(37);
	coded(35)	:=	data_parity_in(38);
	coded(36)	:=	data_parity_in(39);
	coded(37)	:=	data_parity_in(40);
	coded(38)	:=	data_parity_in(41);
	coded(39)	:=	data_parity_in(42);
	coded(40)	:=	data_parity_in(43);
	coded(41)	:=	data_parity_in(44);
	coded(42)	:=	data_parity_in(45);
	coded(43)	:=	data_parity_in(46);
	coded(44)	:=	data_parity_in(47);
	coded(45)	:=	data_parity_in(48);
	coded(46)	:=	data_parity_in(49);
	coded(47)	:=	data_parity_in(50);
	coded(48)	:=	data_parity_in(51);
	coded(49)	:=	data_parity_in(52);
	coded(50)	:=	data_parity_in(53);
	coded(51)	:=	data_parity_in(54);
	coded(52)	:=	data_parity_in(55);
	coded(53)	:=	data_parity_in(56);
	coded(54)	:=	data_parity_in(57);
	coded(55)	:=	data_parity_in(58);
	coded(56)	:=	data_parity_in(59);
	coded(57)	:=	data_parity_in(60);
	coded(58)	:=	data_parity_in(61);
	coded(59)	:=	data_parity_in(62);
	coded(60)	:=	data_parity_in(63);
	coded(61)	:=	data_parity_in(64);
	coded(62)	:=	data_parity_in(65);
	coded(63)	:=	data_parity_in(66);
	coded(65)	:=	data_parity_in(67);
	coded(66)	:=	data_parity_in(68);
	coded(67)	:=	data_parity_in(69);
	coded(68)	:=	data_parity_in(70);
	coded(69)	:=	data_parity_in(71);
	coded(70)	:=	data_parity_in(72);
	coded(71)	:=	data_parity_in(73);
	coded(72)	:=	data_parity_in(74);
	coded(73)	:=	data_parity_in(75);
	coded(74)	:=	data_parity_in(76);
	coded(75)	:=	data_parity_in(77);
	coded(76)	:=	data_parity_in(78);
	coded(77)	:=	data_parity_in(79);
	coded(78)	:=	data_parity_in(80);
	coded(79)	:=	data_parity_in(81);
	coded(80)	:=	data_parity_in(82);
	coded(81)	:=	data_parity_in(83);
	coded(82)	:=	data_parity_in(84);
	coded(83)	:=	data_parity_in(85);
	coded(84)	:=	data_parity_in(86);
	coded(85)	:=	data_parity_in(87);
	coded(86)	:=	data_parity_in(88);
	coded(87)	:=	data_parity_in(89);
	coded(88)	:=	data_parity_in(90);
	coded(89)	:=	data_parity_in(91);
	coded(90)	:=	data_parity_in(92);
	coded(91)	:=	data_parity_in(93);
	coded(92)	:=	data_parity_in(94);
	coded(93)	:=	data_parity_in(95);
	coded(94)	:=	data_parity_in(96);
	coded(95)	:=	data_parity_in(97);
	coded(96)	:=	data_parity_in(98);
	coded(97)	:=	data_parity_in(99);
	coded(98)	:=	data_parity_in(100);
	coded(99)	:=	data_parity_in(101);
	coded(100)	:=	data_parity_in(102);
	coded(101)	:=	data_parity_in(103);
	coded(102)	:=	data_parity_in(104);
	coded(103)	:=	data_parity_in(105);
	coded(104)	:=	data_parity_in(106);
	coded(105)	:=	data_parity_in(107);
	coded(106)	:=	data_parity_in(108);
	coded(107)	:=	data_parity_in(109);
	coded(108)	:=	data_parity_in(110);
	coded(109)	:=	data_parity_in(111);
	coded(110)	:=	data_parity_in(112);
	coded(111)	:=	data_parity_in(113);
	coded(112)	:=	data_parity_in(114);
	coded(113)	:=	data_parity_in(115);
	coded(114)	:=	data_parity_in(116);
	coded(115)	:=	data_parity_in(117);
	coded(116)	:=	data_parity_in(118);
	coded(117)	:=	data_parity_in(119);
	coded(118)	:=	data_parity_in(120);
	coded(119)	:=	data_parity_in(121);
	coded(120)	:=	data_parity_in(122);
	coded(121)	:=	data_parity_in(123);
	coded(122)	:=	data_parity_in(124);
	coded(123)	:=	data_parity_in(125);
	coded(124)	:=	data_parity_in(126);
	coded(125)	:=	data_parity_in(127);
	coded(126)	:=	data_parity_in(128);
	coded(127)	:=	data_parity_in(129);
	coded(129)	:=	data_parity_in(130);
	coded(130)	:=	data_parity_in(131);
	coded(131)	:=	data_parity_in(132);
	coded(132)	:=	data_parity_in(133);
	coded(133)	:=	data_parity_in(134);
	coded(134)	:=	data_parity_in(135);
	coded(135)	:=	data_parity_in(136);
	coded(136)	:=	data_parity_in(137);
	coded(137)	:=	data_parity_in(138);
	coded(138)	:=	data_parity_in(139);
	coded(139)	:=	data_parity_in(140);
	coded(140)	:=	data_parity_in(141);
	coded(141)	:=	data_parity_in(142);
	coded(142)	:=	data_parity_in(143);
	coded(143)	:=	data_parity_in(144);
	coded(144)	:=	data_parity_in(145);
	coded(145)	:=	data_parity_in(146);
	coded(146)	:=	data_parity_in(147);
	coded(147)	:=	data_parity_in(148);
	coded(148)	:=	data_parity_in(149);
	coded(149)	:=	data_parity_in(150);
	coded(150)	:=	data_parity_in(151);
	coded(151)	:=	data_parity_in(152);
	coded(152)	:=	data_parity_in(153);
	coded(153)	:=	data_parity_in(154);
	coded(154)	:=	data_parity_in(155);
	coded(155)	:=	data_parity_in(156);
	coded(156)	:=	data_parity_in(157);
	coded(157)	:=	data_parity_in(158);
	coded(158)	:=	data_parity_in(159);
	coded(159)	:=	data_parity_in(160);
	coded(160)	:=	data_parity_in(161);
	coded(161)	:=	data_parity_in(162);
	coded(162)	:=	data_parity_in(163);
	coded(163)	:=	data_parity_in(164);
	coded(164)	:=	data_parity_in(165);
	coded(165)	:=	data_parity_in(166);
	coded(166)	:=	data_parity_in(167);
	coded(167)	:=	data_parity_in(168);
	coded(168)	:=	data_parity_in(169);
	coded(169)	:=	data_parity_in(170);
	coded(170)	:=	data_parity_in(171);
	coded(171)	:=	data_parity_in(172);
	coded(172)	:=	data_parity_in(173);
	coded(173)	:=	data_parity_in(174);
	coded(174)	:=	data_parity_in(175);
	coded(175)	:=	data_parity_in(176);
	coded(176)	:=	data_parity_in(177);
	coded(177)	:=	data_parity_in(178);
	coded(178)	:=	data_parity_in(179);
	coded(179)	:=	data_parity_in(180);
	coded(180)	:=	data_parity_in(181);
	coded(181)	:=	data_parity_in(182);
	coded(182)	:=	data_parity_in(183);
	coded(183)	:=	data_parity_in(184);
	coded(184)	:=	data_parity_in(185);
	coded(185)	:=	data_parity_in(186);
	coded(186)	:=	data_parity_in(187);
	coded(187)	:=	data_parity_in(188);
	coded(188)	:=	data_parity_in(189);
	coded(189)	:=	data_parity_in(190);
	coded(190)	:=	data_parity_in(191);
	coded(191)	:=	data_parity_in(192);
	coded(192)	:=	data_parity_in(193);
	coded(193)	:=	data_parity_in(194);
	coded(194)	:=	data_parity_in(195);
	coded(195)	:=	data_parity_in(196);
	coded(196)	:=	data_parity_in(197);
	coded(197)	:=	data_parity_in(198);
	coded(198)	:=	data_parity_in(199);
	coded(199)	:=	data_parity_in(200);
	coded(200)	:=	data_parity_in(201);
	coded(201)	:=	data_parity_in(202);
	coded(202)	:=	data_parity_in(203);
	coded(203)	:=	data_parity_in(204);
	coded(204)	:=	data_parity_in(205);
	coded(205)	:=	data_parity_in(206);
	coded(206)	:=	data_parity_in(207);
	coded(207)	:=	data_parity_in(208);
	coded(208)	:=	data_parity_in(209);
	coded(209)	:=	data_parity_in(210);
	coded(210)	:=	data_parity_in(211);
	coded(211)	:=	data_parity_in(212);
	coded(212)	:=	data_parity_in(213);
	coded(213)	:=	data_parity_in(214);
	coded(214)	:=	data_parity_in(215);
	coded(215)	:=	data_parity_in(216);
	coded(216)	:=	data_parity_in(217);
	coded(217)	:=	data_parity_in(218);
	coded(218)	:=	data_parity_in(219);
	coded(219)	:=	data_parity_in(220);
	coded(220)	:=	data_parity_in(221);
	coded(221)	:=	data_parity_in(222);
	coded(222)	:=	data_parity_in(223);
	coded(223)	:=	data_parity_in(224);
	coded(224)	:=	data_parity_in(225);
	coded(225)	:=	data_parity_in(226);
	coded(226)	:=	data_parity_in(227);
	coded(227)	:=	data_parity_in(228);
	coded(228)	:=	data_parity_in(229);
	coded(229)	:=	data_parity_in(230);
	coded(230)	:=	data_parity_in(231);
	coded(231)	:=	data_parity_in(232);
	coded(232)	:=	data_parity_in(233);
	coded(233)	:=	data_parity_in(234);
	coded(234)	:=	data_parity_in(235);
	coded(235)	:=	data_parity_in(236);
	coded(236)	:=	data_parity_in(237);
	coded(237)	:=	data_parity_in(238);
	coded(238)	:=	data_parity_in(239);
	coded(239)	:=	data_parity_in(240);
	coded(240)	:=	data_parity_in(241);
	coded(241)	:=	data_parity_in(242);
	coded(242)	:=	data_parity_in(243);
	coded(243)	:=	data_parity_in(244);
	coded(244)	:=	data_parity_in(245);
	coded(245)	:=	data_parity_in(246);
	coded(246)	:=	data_parity_in(247);
	coded(247)	:=	data_parity_in(248);
	coded(248)	:=	data_parity_in(249);
	coded(249)	:=	data_parity_in(250);
	coded(250)	:=	data_parity_in(251);
	coded(251)	:=	data_parity_in(252);
	coded(252)	:=	data_parity_in(253);
	coded(253)	:=	data_parity_in(254);
	coded(254)	:=	data_parity_in(255);
	coded(255)	:=	data_parity_in(256);
	coded(257)	:=	data_parity_in(257);
	coded(258)	:=	data_parity_in(258);
	coded(259)	:=	data_parity_in(259);
	coded(260)	:=	data_parity_in(260);
	coded(261)	:=	data_parity_in(261);
	coded(262)	:=	data_parity_in(262);
	coded(263)	:=	data_parity_in(263);
	coded(264)	:=	data_parity_in(264);
	coded(265)	:=	data_parity_in(265);
	coded(266)	:=	data_parity_in(266);
	coded(267)	:=	data_parity_in(267);
	coded(268)	:=	data_parity_in(268);
	coded(269)	:=	data_parity_in(269);
	coded(270)	:=	data_parity_in(270);
	coded(271)	:=	data_parity_in(271);
	coded(272)	:=	data_parity_in(272);
	coded(273)	:=	data_parity_in(273);
	coded(274)	:=	data_parity_in(274);
	coded(275)	:=	data_parity_in(275);
	coded(276)	:=	data_parity_in(276);
	coded(277)	:=	data_parity_in(277);
	coded(278)	:=	data_parity_in(278);
	coded(279)	:=	data_parity_in(279);
	coded(280)	:=	data_parity_in(280);
	coded(281)	:=	data_parity_in(281);
	coded(282)	:=	data_parity_in(282);
	coded(283)	:=	data_parity_in(283);
	coded(284)	:=	data_parity_in(284);
	coded(285)	:=	data_parity_in(285);
	coded(286)	:=	data_parity_in(286);
	coded(287)	:=	data_parity_in(287);
	coded(288)	:=	data_parity_in(288);
	coded(289)	:=	data_parity_in(289);
	coded(290)	:=	data_parity_in(290);
	coded(291)	:=	data_parity_in(291);
	coded(292)	:=	data_parity_in(292);
	coded(293)	:=	data_parity_in(293);
	coded(294)	:=	data_parity_in(294);
	coded(295)	:=	data_parity_in(295);
	coded(296)	:=	data_parity_in(296);
	coded(297)	:=	data_parity_in(297);
	coded(298)	:=	data_parity_in(298);
	coded(299)	:=	data_parity_in(299);
	coded(300)	:=	data_parity_in(300);
	coded(301)	:=	data_parity_in(301);
	coded(302)	:=	data_parity_in(302);
	coded(303)	:=	data_parity_in(303);
	coded(304)	:=	data_parity_in(304);
	coded(305)	:=	data_parity_in(305);
	coded(306)	:=	data_parity_in(306);
	coded(307)	:=	data_parity_in(307);
	coded(308)	:=	data_parity_in(308);
	coded(309)	:=	data_parity_in(309);
	coded(310)	:=	data_parity_in(310);
	coded(311)	:=	data_parity_in(311);
	coded(312)	:=	data_parity_in(312);
	coded(313)	:=	data_parity_in(313);
	coded(314)	:=	data_parity_in(314);
	coded(315)	:=	data_parity_in(315);
	coded(316)	:=	data_parity_in(316);
	coded(317)	:=	data_parity_in(317);
	coded(318)	:=	data_parity_in(318);
	coded(319)	:=	data_parity_in(319);
	coded(320)	:=	data_parity_in(320);
	coded(321)	:=	data_parity_in(321);
	coded(322)	:=	data_parity_in(322);
	coded(323)	:=	data_parity_in(323);
	coded(324)	:=	data_parity_in(324);
	coded(325)	:=	data_parity_in(325);
	coded(326)	:=	data_parity_in(326);
	coded(327)	:=	data_parity_in(327);
	coded(328)	:=	data_parity_in(328);
	coded(329)	:=	data_parity_in(329);
	coded(330)	:=	data_parity_in(330);
	coded(331)	:=	data_parity_in(331);
	coded(332)	:=	data_parity_in(332);
	coded(333)	:=	data_parity_in(333);
	coded(334)	:=	data_parity_in(334);
	coded(335)	:=	data_parity_in(335);
	coded(336)	:=	data_parity_in(336);
	coded(337)	:=	data_parity_in(337);
	coded(338)	:=	data_parity_in(338);
	coded(339)	:=	data_parity_in(339);
	coded(340)	:=	data_parity_in(340);
	coded(341)	:=	data_parity_in(341);
	coded(342)	:=	data_parity_in(342);
	coded(343)	:=	data_parity_in(343);
	coded(344)	:=	data_parity_in(344);
	coded(345)	:=	data_parity_in(345);
	coded(346)	:=	data_parity_in(346);
	coded(347)	:=	data_parity_in(347);
	coded(348)	:=	data_parity_in(348);
	coded(349)	:=	data_parity_in(349);
	coded(350)	:=	data_parity_in(350);
	coded(351)	:=	data_parity_in(351);
	coded(352)	:=	data_parity_in(352);
	coded(353)	:=	data_parity_in(353);
	coded(354)	:=	data_parity_in(354);
	coded(355)	:=	data_parity_in(355);
	coded(356)	:=	data_parity_in(356);
	coded(357)	:=	data_parity_in(357);
	coded(358)	:=	data_parity_in(358);
	coded(359)	:=	data_parity_in(359);
	coded(360)	:=	data_parity_in(360);
	coded(361)	:=	data_parity_in(361);
	coded(362)	:=	data_parity_in(362);
	coded(363)	:=	data_parity_in(363);
	coded(364)	:=	data_parity_in(364);
	coded(365)	:=	data_parity_in(365);
	coded(366)	:=	data_parity_in(366);
	coded(367)	:=	data_parity_in(367);
	coded(368)	:=	data_parity_in(368);
	coded(369)	:=	data_parity_in(369);
	coded(370)	:=	data_parity_in(370);
	coded(371)	:=	data_parity_in(371);
	coded(372)	:=	data_parity_in(372);
	coded(373)	:=	data_parity_in(373);
	coded(374)	:=	data_parity_in(374);
	coded(375)	:=	data_parity_in(375);
	coded(376)	:=	data_parity_in(376);
	coded(377)	:=	data_parity_in(377);
	coded(378)	:=	data_parity_in(378);
	coded(379)	:=	data_parity_in(379);
	coded(380)	:=	data_parity_in(380);
	coded(381)	:=	data_parity_in(381);
	coded(382)	:=	data_parity_in(382);
	coded(383)	:=	data_parity_in(383);
	coded(384)	:=	data_parity_in(384);
	coded(385)	:=	data_parity_in(385);
	coded(386)	:=	data_parity_in(386);
	coded(387)	:=	data_parity_in(387);
	coded(388)	:=	data_parity_in(388);
	coded(389)	:=	data_parity_in(389);
	coded(390)	:=	data_parity_in(390);
	coded(391)	:=	data_parity_in(391);
	coded(392)	:=	data_parity_in(392);
	coded(393)	:=	data_parity_in(393);
	coded(394)	:=	data_parity_in(394);
	coded(395)	:=	data_parity_in(395);
	coded(396)	:=	data_parity_in(396);
	coded(397)	:=	data_parity_in(397);
	coded(398)	:=	data_parity_in(398);
	coded(399)	:=	data_parity_in(399);
	coded(400)	:=	data_parity_in(400);
	coded(401)	:=	data_parity_in(401);
	coded(402)	:=	data_parity_in(402);
	coded(403)	:=	data_parity_in(403);
	coded(404)	:=	data_parity_in(404);
	coded(405)	:=	data_parity_in(405);
	coded(406)	:=	data_parity_in(406);
	coded(407)	:=	data_parity_in(407);
	coded(408)	:=	data_parity_in(408);
	coded(409)	:=	data_parity_in(409);
	coded(410)	:=	data_parity_in(410);
	coded(411)	:=	data_parity_in(411);
	coded(412)	:=	data_parity_in(412);
	coded(413)	:=	data_parity_in(413);
	coded(414)	:=	data_parity_in(414);
	coded(415)	:=	data_parity_in(415);
	coded(416)	:=	data_parity_in(416);
	coded(417)	:=	data_parity_in(417);
	coded(418)	:=	data_parity_in(418);
	coded(419)	:=	data_parity_in(419);
	coded(420)	:=	data_parity_in(420);
	coded(421)	:=	data_parity_in(421);
	coded(422)	:=	data_parity_in(422);
	coded(423)	:=	data_parity_in(423);
	coded(424)	:=	data_parity_in(424);
	coded(425)	:=	data_parity_in(425);
	coded(426)	:=	data_parity_in(426);
	coded(427)	:=	data_parity_in(427);
	coded(428)	:=	data_parity_in(428);
	coded(429)	:=	data_parity_in(429);
	coded(430)	:=	data_parity_in(430);
	coded(431)	:=	data_parity_in(431);
	coded(432)	:=	data_parity_in(432);
	coded(433)	:=	data_parity_in(433);
	coded(434)	:=	data_parity_in(434);
	coded(435)	:=	data_parity_in(435);
	coded(436)	:=	data_parity_in(436);
	coded(437)	:=	data_parity_in(437);
	coded(438)	:=	data_parity_in(438);
	coded(439)	:=	data_parity_in(439);
	coded(440)	:=	data_parity_in(440);
	coded(441)	:=	data_parity_in(441);
	coded(442)	:=	data_parity_in(442);
	coded(443)	:=	data_parity_in(443);
	coded(444)	:=	data_parity_in(444);
	coded(445)	:=	data_parity_in(445);
	coded(446)	:=	data_parity_in(446);
	coded(447)	:=	data_parity_in(447);
	coded(448)	:=	data_parity_in(448);
	coded(449)	:=	data_parity_in(449);
	coded(450)	:=	data_parity_in(450);
	coded(451)	:=	data_parity_in(451);
	coded(452)	:=	data_parity_in(452);
	coded(453)	:=	data_parity_in(453);
	coded(454)	:=	data_parity_in(454);
	coded(455)	:=	data_parity_in(455);
	coded(456)	:=	data_parity_in(456);
	coded(457)	:=	data_parity_in(457);
	coded(458)	:=	data_parity_in(458);
	coded(459)	:=	data_parity_in(459);
	coded(460)	:=	data_parity_in(460);
	coded(461)	:=	data_parity_in(461);
	coded(462)	:=	data_parity_in(462);
	coded(463)	:=	data_parity_in(463);
	coded(464)	:=	data_parity_in(464);
	coded(465)	:=	data_parity_in(465);
	coded(466)	:=	data_parity_in(466);
	coded(467)	:=	data_parity_in(467);
	coded(468)	:=	data_parity_in(468);
	coded(469)	:=	data_parity_in(469);
	coded(470)	:=	data_parity_in(470);
	coded(471)	:=	data_parity_in(471);
	coded(472)	:=	data_parity_in(472);
	coded(473)	:=	data_parity_in(473);
	coded(474)	:=	data_parity_in(474);
	coded(475)	:=	data_parity_in(475);
	coded(476)	:=	data_parity_in(476);
	coded(477)	:=	data_parity_in(477);
	coded(478)	:=	data_parity_in(478);
	coded(479)	:=	data_parity_in(479);
	coded(480)	:=	data_parity_in(480);
	coded(481)	:=	data_parity_in(481);
	coded(482)	:=	data_parity_in(482);
	coded(483)	:=	data_parity_in(483);
	coded(484)	:=	data_parity_in(484);
	coded(485)	:=	data_parity_in(485);
	coded(486)	:=	data_parity_in(486);
	coded(487)	:=	data_parity_in(487);
	coded(488)	:=	data_parity_in(488);
	coded(489)	:=	data_parity_in(489);
	coded(490)	:=	data_parity_in(490);
	coded(491)	:=	data_parity_in(491);
	coded(492)	:=	data_parity_in(492);
	coded(493)	:=	data_parity_in(493);
	coded(494)	:=	data_parity_in(494);
	coded(495)	:=	data_parity_in(495);
	coded(496)	:=	data_parity_in(496);
	coded(497)	:=	data_parity_in(497);
	coded(498)	:=	data_parity_in(498);
	coded(499)	:=	data_parity_in(499);
	coded(500)	:=	data_parity_in(500);
	coded(501)	:=	data_parity_in(501);
	coded(502)	:=	data_parity_in(502);
	coded(503)	:=	data_parity_in(503);
	coded(504)	:=	data_parity_in(504);
	coded(505)	:=	data_parity_in(505);

	-- syndorme generation
	syn(9 DOWNTO 1) := parity(9 DOWNTO 1) XOR parity_in(9 DOWNTO 1);
	P0 := '0';
	P1 := '0';
	FOR i IN 0 TO 9 LOOP
		P0 := P0 XOR parity(i);
		P1 := P1 XOR parity_in(i);
	END LOOP;
	syn(0) := P0 XOR P1;

	CASE syn(9 DOWNTO 1) IS
		WHEN "000000011" => syndrome := 3;
		WHEN "000000101" => syndrome := 5;
		WHEN "000000110" => syndrome := 6;
		WHEN "000000111" => syndrome := 7;
		WHEN "000001001" => syndrome := 9;
		WHEN "000001010" => syndrome := 10;
		WHEN "000001011" => syndrome := 11;
		WHEN "000001100" => syndrome := 12;
		WHEN "000001101" => syndrome := 13;
		WHEN "000001110" => syndrome := 14;
		WHEN "000001111" => syndrome := 15;
		WHEN "000010001" => syndrome := 17;
		WHEN "000010010" => syndrome := 18;
		WHEN "000010011" => syndrome := 19;
		WHEN "000010100" => syndrome := 20;
		WHEN "000010101" => syndrome := 21;
		WHEN "000010110" => syndrome := 22;
		WHEN "000010111" => syndrome := 23;
		WHEN "000011000" => syndrome := 24;
		WHEN "000011001" => syndrome := 25;
		WHEN "000011010" => syndrome := 26;
		WHEN "000011011" => syndrome := 27;
		WHEN "000011100" => syndrome := 28;
		WHEN "000011101" => syndrome := 29;
		WHEN "000011110" => syndrome := 30;
		WHEN "000011111" => syndrome := 31;
		WHEN "000100001" => syndrome := 33;
		WHEN "000100010" => syndrome := 34;
		WHEN "000100011" => syndrome := 35;
		WHEN "000100100" => syndrome := 36;
		WHEN "000100101" => syndrome := 37;
		WHEN "000100110" => syndrome := 38;
		WHEN "000100111" => syndrome := 39;
		WHEN "000101000" => syndrome := 40;
		WHEN "000101001" => syndrome := 41;
		WHEN "000101010" => syndrome := 42;
		WHEN "000101011" => syndrome := 43;
		WHEN "000101100" => syndrome := 44;
		WHEN "000101101" => syndrome := 45;
		WHEN "000101110" => syndrome := 46;
		WHEN "000101111" => syndrome := 47;
		WHEN "000110000" => syndrome := 48;
		WHEN "000110001" => syndrome := 49;
		WHEN "000110010" => syndrome := 50;
		WHEN "000110011" => syndrome := 51;
		WHEN "000110100" => syndrome := 52;
		WHEN "000110101" => syndrome := 53;
		WHEN "000110110" => syndrome := 54;
		WHEN "000110111" => syndrome := 55;
		WHEN "000111000" => syndrome := 56;
		WHEN "000111001" => syndrome := 57;
		WHEN "000111010" => syndrome := 58;
		WHEN "000111011" => syndrome := 59;
		WHEN "000111100" => syndrome := 60;
		WHEN "000111101" => syndrome := 61;
		WHEN "000111110" => syndrome := 62;
		WHEN "000111111" => syndrome := 63;
		WHEN "001000001" => syndrome := 65;
		WHEN "001000010" => syndrome := 66;
		WHEN "001000011" => syndrome := 67;
		WHEN "001000100" => syndrome := 68;
		WHEN "001000101" => syndrome := 69;
		WHEN "001000110" => syndrome := 70;
		WHEN "001000111" => syndrome := 71;
		WHEN "001001000" => syndrome := 72;
		WHEN "001001001" => syndrome := 73;
		WHEN "001001010" => syndrome := 74;
		WHEN "001001011" => syndrome := 75;
		WHEN "001001100" => syndrome := 76;
		WHEN "001001101" => syndrome := 77;
		WHEN "001001110" => syndrome := 78;
		WHEN "001001111" => syndrome := 79;
		WHEN "001010000" => syndrome := 80;
		WHEN "001010001" => syndrome := 81;
		WHEN "001010010" => syndrome := 82;
		WHEN "001010011" => syndrome := 83;
		WHEN "001010100" => syndrome := 84;
		WHEN "001010101" => syndrome := 85;
		WHEN "001010110" => syndrome := 86;
		WHEN "001010111" => syndrome := 87;
		WHEN "001011000" => syndrome := 88;
		WHEN "001011001" => syndrome := 89;
		WHEN "001011010" => syndrome := 90;
		WHEN "001011011" => syndrome := 91;
		WHEN "001011100" => syndrome := 92;
		WHEN "001011101" => syndrome := 93;
		WHEN "001011110" => syndrome := 94;
		WHEN "001011111" => syndrome := 95;
		WHEN "001100000" => syndrome := 96;
		WHEN "001100001" => syndrome := 97;
		WHEN "001100010" => syndrome := 98;
		WHEN "001100011" => syndrome := 99;
		WHEN "001100100" => syndrome := 100;
		WHEN "001100101" => syndrome := 101;
		WHEN "001100110" => syndrome := 102;
		WHEN "001100111" => syndrome := 103;
		WHEN "001101000" => syndrome := 104;
		WHEN "001101001" => syndrome := 105;
		WHEN "001101010" => syndrome := 106;
		WHEN "001101011" => syndrome := 107;
		WHEN "001101100" => syndrome := 108;
		WHEN "001101101" => syndrome := 109;
		WHEN "001101110" => syndrome := 110;
		WHEN "001101111" => syndrome := 111;
		WHEN "001110000" => syndrome := 112;
		WHEN "001110001" => syndrome := 113;
		WHEN "001110010" => syndrome := 114;
		WHEN "001110011" => syndrome := 115;
		WHEN "001110100" => syndrome := 116;
		WHEN "001110101" => syndrome := 117;
		WHEN "001110110" => syndrome := 118;
		WHEN "001110111" => syndrome := 119;
		WHEN "001111000" => syndrome := 120;
		WHEN "001111001" => syndrome := 121;
		WHEN "001111010" => syndrome := 122;
		WHEN "001111011" => syndrome := 123;
		WHEN "001111100" => syndrome := 124;
		WHEN "001111101" => syndrome := 125;
		WHEN "001111110" => syndrome := 126;
		WHEN "001111111" => syndrome := 127;
		WHEN "010000001" => syndrome := 129;
		WHEN "010000010" => syndrome := 130;
		WHEN "010000011" => syndrome := 131;
		WHEN "010000100" => syndrome := 132;
		WHEN "010000101" => syndrome := 133;
		WHEN "010000110" => syndrome := 134;
		WHEN "010000111" => syndrome := 135;
		WHEN "010001000" => syndrome := 136;
		WHEN "010001001" => syndrome := 137;
		WHEN "010001010" => syndrome := 138;
		WHEN "010001011" => syndrome := 139;
		WHEN "010001100" => syndrome := 140;
		WHEN "010001101" => syndrome := 141;
		WHEN "010001110" => syndrome := 142;
		WHEN "010001111" => syndrome := 143;
		WHEN "010010000" => syndrome := 144;
		WHEN "010010001" => syndrome := 145;
		WHEN "010010010" => syndrome := 146;
		WHEN "010010011" => syndrome := 147;
		WHEN "010010100" => syndrome := 148;
		WHEN "010010101" => syndrome := 149;
		WHEN "010010110" => syndrome := 150;
		WHEN "010010111" => syndrome := 151;
		WHEN "010011000" => syndrome := 152;
		WHEN "010011001" => syndrome := 153;
		WHEN "010011010" => syndrome := 154;
		WHEN "010011011" => syndrome := 155;
		WHEN "010011100" => syndrome := 156;
		WHEN "010011101" => syndrome := 157;
		WHEN "010011110" => syndrome := 158;
		WHEN "010011111" => syndrome := 159;
		WHEN "010100000" => syndrome := 160;
		WHEN "010100001" => syndrome := 161;
		WHEN "010100010" => syndrome := 162;
		WHEN "010100011" => syndrome := 163;
		WHEN "010100100" => syndrome := 164;
		WHEN "010100101" => syndrome := 165;
		WHEN "010100110" => syndrome := 166;
		WHEN "010100111" => syndrome := 167;
		WHEN "010101000" => syndrome := 168;
		WHEN "010101001" => syndrome := 169;
		WHEN "010101010" => syndrome := 170;
		WHEN "010101011" => syndrome := 171;
		WHEN "010101100" => syndrome := 172;
		WHEN "010101101" => syndrome := 173;
		WHEN "010101110" => syndrome := 174;
		WHEN "010101111" => syndrome := 175;
		WHEN "010110000" => syndrome := 176;
		WHEN "010110001" => syndrome := 177;
		WHEN "010110010" => syndrome := 178;
		WHEN "010110011" => syndrome := 179;
		WHEN "010110100" => syndrome := 180;
		WHEN "010110101" => syndrome := 181;
		WHEN "010110110" => syndrome := 182;
		WHEN "010110111" => syndrome := 183;
		WHEN "010111000" => syndrome := 184;
		WHEN "010111001" => syndrome := 185;
		WHEN "010111010" => syndrome := 186;
		WHEN "010111011" => syndrome := 187;
		WHEN "010111100" => syndrome := 188;
		WHEN "010111101" => syndrome := 189;
		WHEN "010111110" => syndrome := 190;
		WHEN "010111111" => syndrome := 191;
		WHEN "011000000" => syndrome := 192;
		WHEN "011000001" => syndrome := 193;
		WHEN "011000010" => syndrome := 194;
		WHEN "011000011" => syndrome := 195;
		WHEN "011000100" => syndrome := 196;
		WHEN "011000101" => syndrome := 197;
		WHEN "011000110" => syndrome := 198;
		WHEN "011000111" => syndrome := 199;
		WHEN "011001000" => syndrome := 200;
		WHEN "011001001" => syndrome := 201;
		WHEN "011001010" => syndrome := 202;
		WHEN "011001011" => syndrome := 203;
		WHEN "011001100" => syndrome := 204;
		WHEN "011001101" => syndrome := 205;
		WHEN "011001110" => syndrome := 206;
		WHEN "011001111" => syndrome := 207;
		WHEN "011010000" => syndrome := 208;
		WHEN "011010001" => syndrome := 209;
		WHEN "011010010" => syndrome := 210;
		WHEN "011010011" => syndrome := 211;
		WHEN "011010100" => syndrome := 212;
		WHEN "011010101" => syndrome := 213;
		WHEN "011010110" => syndrome := 214;
		WHEN "011010111" => syndrome := 215;
		WHEN "011011000" => syndrome := 216;
		WHEN "011011001" => syndrome := 217;
		WHEN "011011010" => syndrome := 218;
		WHEN "011011011" => syndrome := 219;
		WHEN "011011100" => syndrome := 220;
		WHEN "011011101" => syndrome := 221;
		WHEN "011011110" => syndrome := 222;
		WHEN "011011111" => syndrome := 223;
		WHEN "011100000" => syndrome := 224;
		WHEN "011100001" => syndrome := 225;
		WHEN "011100010" => syndrome := 226;
		WHEN "011100011" => syndrome := 227;
		WHEN "011100100" => syndrome := 228;
		WHEN "011100101" => syndrome := 229;
		WHEN "011100110" => syndrome := 230;
		WHEN "011100111" => syndrome := 231;
		WHEN "011101000" => syndrome := 232;
		WHEN "011101001" => syndrome := 233;
		WHEN "011101010" => syndrome := 234;
		WHEN "011101011" => syndrome := 235;
		WHEN "011101100" => syndrome := 236;
		WHEN "011101101" => syndrome := 237;
		WHEN "011101110" => syndrome := 238;
		WHEN "011101111" => syndrome := 239;
		WHEN "011110000" => syndrome := 240;
		WHEN "011110001" => syndrome := 241;
		WHEN "011110010" => syndrome := 242;
		WHEN "011110011" => syndrome := 243;
		WHEN "011110100" => syndrome := 244;
		WHEN "011110101" => syndrome := 245;
		WHEN "011110110" => syndrome := 246;
		WHEN "011110111" => syndrome := 247;
		WHEN "011111000" => syndrome := 248;
		WHEN "011111001" => syndrome := 249;
		WHEN "011111010" => syndrome := 250;
		WHEN "011111011" => syndrome := 251;
		WHEN "011111100" => syndrome := 252;
		WHEN "011111101" => syndrome := 253;
		WHEN "011111110" => syndrome := 254;
		WHEN "011111111" => syndrome := 255;
		WHEN "100000001" => syndrome := 257;
		WHEN "100000010" => syndrome := 258;
		WHEN "100000011" => syndrome := 259;
		WHEN "100000100" => syndrome := 260;
		WHEN "100000101" => syndrome := 261;
		WHEN "100000110" => syndrome := 262;
		WHEN "100000111" => syndrome := 263;
		WHEN "100001000" => syndrome := 264;
		WHEN "100001001" => syndrome := 265;
		WHEN "100001010" => syndrome := 266;
		WHEN "100001011" => syndrome := 267;
		WHEN "100001100" => syndrome := 268;
		WHEN "100001101" => syndrome := 269;
		WHEN "100001110" => syndrome := 270;
		WHEN "100001111" => syndrome := 271;
		WHEN "100010000" => syndrome := 272;
		WHEN "100010001" => syndrome := 273;
		WHEN "100010010" => syndrome := 274;
		WHEN "100010011" => syndrome := 275;
		WHEN "100010100" => syndrome := 276;
		WHEN "100010101" => syndrome := 277;
		WHEN "100010110" => syndrome := 278;
		WHEN "100010111" => syndrome := 279;
		WHEN "100011000" => syndrome := 280;
		WHEN "100011001" => syndrome := 281;
		WHEN "100011010" => syndrome := 282;
		WHEN "100011011" => syndrome := 283;
		WHEN "100011100" => syndrome := 284;
		WHEN "100011101" => syndrome := 285;
		WHEN "100011110" => syndrome := 286;
		WHEN "100011111" => syndrome := 287;
		WHEN "100100000" => syndrome := 288;
		WHEN "100100001" => syndrome := 289;
		WHEN "100100010" => syndrome := 290;
		WHEN "100100011" => syndrome := 291;
		WHEN "100100100" => syndrome := 292;
		WHEN "100100101" => syndrome := 293;
		WHEN "100100110" => syndrome := 294;
		WHEN "100100111" => syndrome := 295;
		WHEN "100101000" => syndrome := 296;
		WHEN "100101001" => syndrome := 297;
		WHEN "100101010" => syndrome := 298;
		WHEN "100101011" => syndrome := 299;
		WHEN "100101100" => syndrome := 300;
		WHEN "100101101" => syndrome := 301;
		WHEN "100101110" => syndrome := 302;
		WHEN "100101111" => syndrome := 303;
		WHEN "100110000" => syndrome := 304;
		WHEN "100110001" => syndrome := 305;
		WHEN "100110010" => syndrome := 306;
		WHEN "100110011" => syndrome := 307;
		WHEN "100110100" => syndrome := 308;
		WHEN "100110101" => syndrome := 309;
		WHEN "100110110" => syndrome := 310;
		WHEN "100110111" => syndrome := 311;
		WHEN "100111000" => syndrome := 312;
		WHEN "100111001" => syndrome := 313;
		WHEN "100111010" => syndrome := 314;
		WHEN "100111011" => syndrome := 315;
		WHEN "100111100" => syndrome := 316;
		WHEN "100111101" => syndrome := 317;
		WHEN "100111110" => syndrome := 318;
		WHEN "100111111" => syndrome := 319;
		WHEN "101000000" => syndrome := 320;
		WHEN "101000001" => syndrome := 321;
		WHEN "101000010" => syndrome := 322;
		WHEN "101000011" => syndrome := 323;
		WHEN "101000100" => syndrome := 324;
		WHEN "101000101" => syndrome := 325;
		WHEN "101000110" => syndrome := 326;
		WHEN "101000111" => syndrome := 327;
		WHEN "101001000" => syndrome := 328;
		WHEN "101001001" => syndrome := 329;
		WHEN "101001010" => syndrome := 330;
		WHEN "101001011" => syndrome := 331;
		WHEN "101001100" => syndrome := 332;
		WHEN "101001101" => syndrome := 333;
		WHEN "101001110" => syndrome := 334;
		WHEN "101001111" => syndrome := 335;
		WHEN "101010000" => syndrome := 336;
		WHEN "101010001" => syndrome := 337;
		WHEN "101010010" => syndrome := 338;
		WHEN "101010011" => syndrome := 339;
		WHEN "101010100" => syndrome := 340;
		WHEN "101010101" => syndrome := 341;
		WHEN "101010110" => syndrome := 342;
		WHEN "101010111" => syndrome := 343;
		WHEN "101011000" => syndrome := 344;
		WHEN "101011001" => syndrome := 345;
		WHEN "101011010" => syndrome := 346;
		WHEN "101011011" => syndrome := 347;
		WHEN "101011100" => syndrome := 348;
		WHEN "101011101" => syndrome := 349;
		WHEN "101011110" => syndrome := 350;
		WHEN "101011111" => syndrome := 351;
		WHEN "101100000" => syndrome := 352;
		WHEN "101100001" => syndrome := 353;
		WHEN "101100010" => syndrome := 354;
		WHEN "101100011" => syndrome := 355;
		WHEN "101100100" => syndrome := 356;
		WHEN "101100101" => syndrome := 357;
		WHEN "101100110" => syndrome := 358;
		WHEN "101100111" => syndrome := 359;
		WHEN "101101000" => syndrome := 360;
		WHEN "101101001" => syndrome := 361;
		WHEN "101101010" => syndrome := 362;
		WHEN "101101011" => syndrome := 363;
		WHEN "101101100" => syndrome := 364;
		WHEN "101101101" => syndrome := 365;
		WHEN "101101110" => syndrome := 366;
		WHEN "101101111" => syndrome := 367;
		WHEN "101110000" => syndrome := 368;
		WHEN "101110001" => syndrome := 369;
		WHEN "101110010" => syndrome := 370;
		WHEN "101110011" => syndrome := 371;
		WHEN "101110100" => syndrome := 372;
		WHEN "101110101" => syndrome := 373;
		WHEN "101110110" => syndrome := 374;
		WHEN "101110111" => syndrome := 375;
		WHEN "101111000" => syndrome := 376;
		WHEN "101111001" => syndrome := 377;
		WHEN "101111010" => syndrome := 378;
		WHEN "101111011" => syndrome := 379;
		WHEN "101111100" => syndrome := 380;
		WHEN "101111101" => syndrome := 381;
		WHEN "101111110" => syndrome := 382;
		WHEN "101111111" => syndrome := 383;
		WHEN "110000000" => syndrome := 384;
		WHEN "110000001" => syndrome := 385;
		WHEN "110000010" => syndrome := 386;
		WHEN "110000011" => syndrome := 387;
		WHEN "110000100" => syndrome := 388;
		WHEN "110000101" => syndrome := 389;
		WHEN "110000110" => syndrome := 390;
		WHEN "110000111" => syndrome := 391;
		WHEN "110001000" => syndrome := 392;
		WHEN "110001001" => syndrome := 393;
		WHEN "110001010" => syndrome := 394;
		WHEN "110001011" => syndrome := 395;
		WHEN "110001100" => syndrome := 396;
		WHEN "110001101" => syndrome := 397;
		WHEN "110001110" => syndrome := 398;
		WHEN "110001111" => syndrome := 399;
		WHEN "110010000" => syndrome := 400;
		WHEN "110010001" => syndrome := 401;
		WHEN "110010010" => syndrome := 402;
		WHEN "110010011" => syndrome := 403;
		WHEN "110010100" => syndrome := 404;
		WHEN "110010101" => syndrome := 405;
		WHEN "110010110" => syndrome := 406;
		WHEN "110010111" => syndrome := 407;
		WHEN "110011000" => syndrome := 408;
		WHEN "110011001" => syndrome := 409;
		WHEN "110011010" => syndrome := 410;
		WHEN "110011011" => syndrome := 411;
		WHEN "110011100" => syndrome := 412;
		WHEN "110011101" => syndrome := 413;
		WHEN "110011110" => syndrome := 414;
		WHEN "110011111" => syndrome := 415;
		WHEN "110100000" => syndrome := 416;
		WHEN "110100001" => syndrome := 417;
		WHEN "110100010" => syndrome := 418;
		WHEN "110100011" => syndrome := 419;
		WHEN "110100100" => syndrome := 420;
		WHEN "110100101" => syndrome := 421;
		WHEN "110100110" => syndrome := 422;
		WHEN "110100111" => syndrome := 423;
		WHEN "110101000" => syndrome := 424;
		WHEN "110101001" => syndrome := 425;
		WHEN "110101010" => syndrome := 426;
		WHEN "110101011" => syndrome := 427;
		WHEN "110101100" => syndrome := 428;
		WHEN "110101101" => syndrome := 429;
		WHEN "110101110" => syndrome := 430;
		WHEN "110101111" => syndrome := 431;
		WHEN "110110000" => syndrome := 432;
		WHEN "110110001" => syndrome := 433;
		WHEN "110110010" => syndrome := 434;
		WHEN "110110011" => syndrome := 435;
		WHEN "110110100" => syndrome := 436;
		WHEN "110110101" => syndrome := 437;
		WHEN "110110110" => syndrome := 438;
		WHEN "110110111" => syndrome := 439;
		WHEN "110111000" => syndrome := 440;
		WHEN "110111001" => syndrome := 441;
		WHEN "110111010" => syndrome := 442;
		WHEN "110111011" => syndrome := 443;
		WHEN "110111100" => syndrome := 444;
		WHEN "110111101" => syndrome := 445;
		WHEN "110111110" => syndrome := 446;
		WHEN "110111111" => syndrome := 447;
		WHEN "111000000" => syndrome := 448;
		WHEN "111000001" => syndrome := 449;
		WHEN "111000010" => syndrome := 450;
		WHEN "111000011" => syndrome := 451;
		WHEN "111000100" => syndrome := 452;
		WHEN "111000101" => syndrome := 453;
		WHEN "111000110" => syndrome := 454;
		WHEN "111000111" => syndrome := 455;
		WHEN "111001000" => syndrome := 456;
		WHEN "111001001" => syndrome := 457;
		WHEN "111001010" => syndrome := 458;
		WHEN "111001011" => syndrome := 459;
		WHEN "111001100" => syndrome := 460;
		WHEN "111001101" => syndrome := 461;
		WHEN "111001110" => syndrome := 462;
		WHEN "111001111" => syndrome := 463;
		WHEN "111010000" => syndrome := 464;
		WHEN "111010001" => syndrome := 465;
		WHEN "111010010" => syndrome := 466;
		WHEN "111010011" => syndrome := 467;
		WHEN "111010100" => syndrome := 468;
		WHEN "111010101" => syndrome := 469;
		WHEN "111010110" => syndrome := 470;
		WHEN "111010111" => syndrome := 471;
		WHEN "111011000" => syndrome := 472;
		WHEN "111011001" => syndrome := 473;
		WHEN "111011010" => syndrome := 474;
		WHEN "111011011" => syndrome := 475;
		WHEN "111011100" => syndrome := 476;
		WHEN "111011101" => syndrome := 477;
		WHEN "111011110" => syndrome := 478;
		WHEN "111011111" => syndrome := 479;
		WHEN "111100000" => syndrome := 480;
		WHEN "111100001" => syndrome := 481;
		WHEN "111100010" => syndrome := 482;
		WHEN "111100011" => syndrome := 483;
		WHEN "111100100" => syndrome := 484;
		WHEN "111100101" => syndrome := 485;
		WHEN "111100110" => syndrome := 486;
		WHEN "111100111" => syndrome := 487;
		WHEN "111101000" => syndrome := 488;
		WHEN "111101001" => syndrome := 489;
		WHEN "111101010" => syndrome := 490;
		WHEN "111101011" => syndrome := 491;
		WHEN "111101100" => syndrome := 492;
		WHEN "111101101" => syndrome := 493;
		WHEN "111101110" => syndrome := 494;
		WHEN "111101111" => syndrome := 495;
		WHEN "111110000" => syndrome := 496;
		WHEN "111110001" => syndrome := 497;
		WHEN "111110010" => syndrome := 498;
		WHEN "111110011" => syndrome := 499;
		WHEN "111110100" => syndrome := 500;
		WHEN "111110101" => syndrome := 501;
		WHEN "111110110" => syndrome := 502;
		WHEN "111110111" => syndrome := 503;
		WHEN "111111000" => syndrome := 504;
		WHEN "111111001" => syndrome := 505;
		WHEN OTHERS =>  syndrome := 0;
	END CASE;

	IF syn(0) = '1'  THEN
		coded(syndrome) := NOT(coded(syndrome));
		error_out <= "01";    -- There is an error
	ELSIF syndrome/= 0 THEN     -- There are more than one error
		coded := (OTHERS => '0');-- FATAL ERROR
		error_out <= "11";
	ELSE
		error_out <= "00"; -- No errors detected
	END IF;
	decoded(0)	<=	coded(3);
	decoded(1)	<=	coded(5);
	decoded(2)	<=	coded(6);
	decoded(3)	<=	coded(7);
	decoded(4)	<=	coded(9);
	decoded(5)	<=	coded(10);
	decoded(6)	<=	coded(11);
	decoded(7)	<=	coded(12);
	decoded(8)	<=	coded(13);
	decoded(9)	<=	coded(14);
	decoded(10)	<=	coded(15);
	decoded(11)	<=	coded(17);
	decoded(12)	<=	coded(18);
	decoded(13)	<=	coded(19);
	decoded(14)	<=	coded(20);
	decoded(15)	<=	coded(21);
	decoded(16)	<=	coded(22);
	decoded(17)	<=	coded(23);
	decoded(18)	<=	coded(24);
	decoded(19)	<=	coded(25);
	decoded(20)	<=	coded(26);
	decoded(21)	<=	coded(27);
	decoded(22)	<=	coded(28);
	decoded(23)	<=	coded(29);
	decoded(24)	<=	coded(30);
	decoded(25)	<=	coded(31);
	decoded(26)	<=	coded(33);
	decoded(27)	<=	coded(34);
	decoded(28)	<=	coded(35);
	decoded(29)	<=	coded(36);
	decoded(30)	<=	coded(37);
	decoded(31)	<=	coded(38);
	decoded(32)	<=	coded(39);
	decoded(33)	<=	coded(40);
	decoded(34)	<=	coded(41);
	decoded(35)	<=	coded(42);
	decoded(36)	<=	coded(43);
	decoded(37)	<=	coded(44);
	decoded(38)	<=	coded(45);
	decoded(39)	<=	coded(46);
	decoded(40)	<=	coded(47);
	decoded(41)	<=	coded(48);
	decoded(42)	<=	coded(49);
	decoded(43)	<=	coded(50);
	decoded(44)	<=	coded(51);
	decoded(45)	<=	coded(52);
	decoded(46)	<=	coded(53);
	decoded(47)	<=	coded(54);
	decoded(48)	<=	coded(55);
	decoded(49)	<=	coded(56);
	decoded(50)	<=	coded(57);
	decoded(51)	<=	coded(58);
	decoded(52)	<=	coded(59);
	decoded(53)	<=	coded(60);
	decoded(54)	<=	coded(61);
	decoded(55)	<=	coded(62);
	decoded(56)	<=	coded(63);
	decoded(57)	<=	coded(65);
	decoded(58)	<=	coded(66);
	decoded(59)	<=	coded(67);
	decoded(60)	<=	coded(68);
	decoded(61)	<=	coded(69);
	decoded(62)	<=	coded(70);
	decoded(63)	<=	coded(71);
	decoded(64)	<=	coded(72);
	decoded(65)	<=	coded(73);
	decoded(66)	<=	coded(74);
	decoded(67)	<=	coded(75);
	decoded(68)	<=	coded(76);
	decoded(69)	<=	coded(77);
	decoded(70)	<=	coded(78);
	decoded(71)	<=	coded(79);
	decoded(72)	<=	coded(80);
	decoded(73)	<=	coded(81);
	decoded(74)	<=	coded(82);
	decoded(75)	<=	coded(83);
	decoded(76)	<=	coded(84);
	decoded(77)	<=	coded(85);
	decoded(78)	<=	coded(86);
	decoded(79)	<=	coded(87);
	decoded(80)	<=	coded(88);
	decoded(81)	<=	coded(89);
	decoded(82)	<=	coded(90);
	decoded(83)	<=	coded(91);
	decoded(84)	<=	coded(92);
	decoded(85)	<=	coded(93);
	decoded(86)	<=	coded(94);
	decoded(87)	<=	coded(95);
	decoded(88)	<=	coded(96);
	decoded(89)	<=	coded(97);
	decoded(90)	<=	coded(98);
	decoded(91)	<=	coded(99);
	decoded(92)	<=	coded(100);
	decoded(93)	<=	coded(101);
	decoded(94)	<=	coded(102);
	decoded(95)	<=	coded(103);
	decoded(96)	<=	coded(104);
	decoded(97)	<=	coded(105);
	decoded(98)	<=	coded(106);
	decoded(99)	<=	coded(107);
	decoded(100)	<=	coded(108);
	decoded(101)	<=	coded(109);
	decoded(102)	<=	coded(110);
	decoded(103)	<=	coded(111);
	decoded(104)	<=	coded(112);
	decoded(105)	<=	coded(113);
	decoded(106)	<=	coded(114);
	decoded(107)	<=	coded(115);
	decoded(108)	<=	coded(116);
	decoded(109)	<=	coded(117);
	decoded(110)	<=	coded(118);
	decoded(111)	<=	coded(119);
	decoded(112)	<=	coded(120);
	decoded(113)	<=	coded(121);
	decoded(114)	<=	coded(122);
	decoded(115)	<=	coded(123);
	decoded(116)	<=	coded(124);
	decoded(117)	<=	coded(125);
	decoded(118)	<=	coded(126);
	decoded(119)	<=	coded(127);
	decoded(120)	<=	coded(129);
	decoded(121)	<=	coded(130);
	decoded(122)	<=	coded(131);
	decoded(123)	<=	coded(132);
	decoded(124)	<=	coded(133);
	decoded(125)	<=	coded(134);
	decoded(126)	<=	coded(135);
	decoded(127)	<=	coded(136);
	decoded(128)	<=	coded(137);
	decoded(129)	<=	coded(138);
	decoded(130)	<=	coded(139);
	decoded(131)	<=	coded(140);
	decoded(132)	<=	coded(141);
	decoded(133)	<=	coded(142);
	decoded(134)	<=	coded(143);
	decoded(135)	<=	coded(144);
	decoded(136)	<=	coded(145);
	decoded(137)	<=	coded(146);
	decoded(138)	<=	coded(147);
	decoded(139)	<=	coded(148);
	decoded(140)	<=	coded(149);
	decoded(141)	<=	coded(150);
	decoded(142)	<=	coded(151);
	decoded(143)	<=	coded(152);
	decoded(144)	<=	coded(153);
	decoded(145)	<=	coded(154);
	decoded(146)	<=	coded(155);
	decoded(147)	<=	coded(156);
	decoded(148)	<=	coded(157);
	decoded(149)	<=	coded(158);
	decoded(150)	<=	coded(159);
	decoded(151)	<=	coded(160);
	decoded(152)	<=	coded(161);
	decoded(153)	<=	coded(162);
	decoded(154)	<=	coded(163);
	decoded(155)	<=	coded(164);
	decoded(156)	<=	coded(165);
	decoded(157)	<=	coded(166);
	decoded(158)	<=	coded(167);
	decoded(159)	<=	coded(168);
	decoded(160)	<=	coded(169);
	decoded(161)	<=	coded(170);
	decoded(162)	<=	coded(171);
	decoded(163)	<=	coded(172);
	decoded(164)	<=	coded(173);
	decoded(165)	<=	coded(174);
	decoded(166)	<=	coded(175);
	decoded(167)	<=	coded(176);
	decoded(168)	<=	coded(177);
	decoded(169)	<=	coded(178);
	decoded(170)	<=	coded(179);
	decoded(171)	<=	coded(180);
	decoded(172)	<=	coded(181);
	decoded(173)	<=	coded(182);
	decoded(174)	<=	coded(183);
	decoded(175)	<=	coded(184);
	decoded(176)	<=	coded(185);
	decoded(177)	<=	coded(186);
	decoded(178)	<=	coded(187);
	decoded(179)	<=	coded(188);
	decoded(180)	<=	coded(189);
	decoded(181)	<=	coded(190);
	decoded(182)	<=	coded(191);
	decoded(183)	<=	coded(192);
	decoded(184)	<=	coded(193);
	decoded(185)	<=	coded(194);
	decoded(186)	<=	coded(195);
	decoded(187)	<=	coded(196);
	decoded(188)	<=	coded(197);
	decoded(189)	<=	coded(198);
	decoded(190)	<=	coded(199);
	decoded(191)	<=	coded(200);
	decoded(192)	<=	coded(201);
	decoded(193)	<=	coded(202);
	decoded(194)	<=	coded(203);
	decoded(195)	<=	coded(204);
	decoded(196)	<=	coded(205);
	decoded(197)	<=	coded(206);
	decoded(198)	<=	coded(207);
	decoded(199)	<=	coded(208);
	decoded(200)	<=	coded(209);
	decoded(201)	<=	coded(210);
	decoded(202)	<=	coded(211);
	decoded(203)	<=	coded(212);
	decoded(204)	<=	coded(213);
	decoded(205)	<=	coded(214);
	decoded(206)	<=	coded(215);
	decoded(207)	<=	coded(216);
	decoded(208)	<=	coded(217);
	decoded(209)	<=	coded(218);
	decoded(210)	<=	coded(219);
	decoded(211)	<=	coded(220);
	decoded(212)	<=	coded(221);
	decoded(213)	<=	coded(222);
	decoded(214)	<=	coded(223);
	decoded(215)	<=	coded(224);
	decoded(216)	<=	coded(225);
	decoded(217)	<=	coded(226);
	decoded(218)	<=	coded(227);
	decoded(219)	<=	coded(228);
	decoded(220)	<=	coded(229);
	decoded(221)	<=	coded(230);
	decoded(222)	<=	coded(231);
	decoded(223)	<=	coded(232);
	decoded(224)	<=	coded(233);
	decoded(225)	<=	coded(234);
	decoded(226)	<=	coded(235);
	decoded(227)	<=	coded(236);
	decoded(228)	<=	coded(237);
	decoded(229)	<=	coded(238);
	decoded(230)	<=	coded(239);
	decoded(231)	<=	coded(240);
	decoded(232)	<=	coded(241);
	decoded(233)	<=	coded(242);
	decoded(234)	<=	coded(243);
	decoded(235)	<=	coded(244);
	decoded(236)	<=	coded(245);
	decoded(237)	<=	coded(246);
	decoded(238)	<=	coded(247);
	decoded(239)	<=	coded(248);
	decoded(240)	<=	coded(249);
	decoded(241)	<=	coded(250);
	decoded(242)	<=	coded(251);
	decoded(243)	<=	coded(252);
	decoded(244)	<=	coded(253);
	decoded(245)	<=	coded(254);
	decoded(246)	<=	coded(255);
	decoded(247)	<=	coded(257);
	decoded(248)	<=	coded(258);
	decoded(249)	<=	coded(259);
	decoded(250)	<=	coded(260);
	decoded(251)	<=	coded(261);
	decoded(252)	<=	coded(262);
	decoded(253)	<=	coded(263);
	decoded(254)	<=	coded(264);
	decoded(255)	<=	coded(265);
	decoded(256)	<=	coded(266);
	decoded(257)	<=	coded(267);
	decoded(258)	<=	coded(268);
	decoded(259)	<=	coded(269);
	decoded(260)	<=	coded(270);
	decoded(261)	<=	coded(271);
	decoded(262)	<=	coded(272);
	decoded(263)	<=	coded(273);
	decoded(264)	<=	coded(274);
	decoded(265)	<=	coded(275);
	decoded(266)	<=	coded(276);
	decoded(267)	<=	coded(277);
	decoded(268)	<=	coded(278);
	decoded(269)	<=	coded(279);
	decoded(270)	<=	coded(280);
	decoded(271)	<=	coded(281);
	decoded(272)	<=	coded(282);
	decoded(273)	<=	coded(283);
	decoded(274)	<=	coded(284);
	decoded(275)	<=	coded(285);
	decoded(276)	<=	coded(286);
	decoded(277)	<=	coded(287);
	decoded(278)	<=	coded(288);
	decoded(279)	<=	coded(289);
	decoded(280)	<=	coded(290);
	decoded(281)	<=	coded(291);
	decoded(282)	<=	coded(292);
	decoded(283)	<=	coded(293);
	decoded(284)	<=	coded(294);
	decoded(285)	<=	coded(295);
	decoded(286)	<=	coded(296);
	decoded(287)	<=	coded(297);
	decoded(288)	<=	coded(298);
	decoded(289)	<=	coded(299);
	decoded(290)	<=	coded(300);
	decoded(291)	<=	coded(301);
	decoded(292)	<=	coded(302);
	decoded(293)	<=	coded(303);
	decoded(294)	<=	coded(304);
	decoded(295)	<=	coded(305);
	decoded(296)	<=	coded(306);
	decoded(297)	<=	coded(307);
	decoded(298)	<=	coded(308);
	decoded(299)	<=	coded(309);
	decoded(300)	<=	coded(310);
	decoded(301)	<=	coded(311);
	decoded(302)	<=	coded(312);
	decoded(303)	<=	coded(313);
	decoded(304)	<=	coded(314);
	decoded(305)	<=	coded(315);
	decoded(306)	<=	coded(316);
	decoded(307)	<=	coded(317);
	decoded(308)	<=	coded(318);
	decoded(309)	<=	coded(319);
	decoded(310)	<=	coded(320);
	decoded(311)	<=	coded(321);
	decoded(312)	<=	coded(322);
	decoded(313)	<=	coded(323);
	decoded(314)	<=	coded(324);
	decoded(315)	<=	coded(325);
	decoded(316)	<=	coded(326);
	decoded(317)	<=	coded(327);
	decoded(318)	<=	coded(328);
	decoded(319)	<=	coded(329);
	decoded(320)	<=	coded(330);
	decoded(321)	<=	coded(331);
	decoded(322)	<=	coded(332);
	decoded(323)	<=	coded(333);
	decoded(324)	<=	coded(334);
	decoded(325)	<=	coded(335);
	decoded(326)	<=	coded(336);
	decoded(327)	<=	coded(337);
	decoded(328)	<=	coded(338);
	decoded(329)	<=	coded(339);
	decoded(330)	<=	coded(340);
	decoded(331)	<=	coded(341);
	decoded(332)	<=	coded(342);
	decoded(333)	<=	coded(343);
	decoded(334)	<=	coded(344);
	decoded(335)	<=	coded(345);
	decoded(336)	<=	coded(346);
	decoded(337)	<=	coded(347);
	decoded(338)	<=	coded(348);
	decoded(339)	<=	coded(349);
	decoded(340)	<=	coded(350);
	decoded(341)	<=	coded(351);
	decoded(342)	<=	coded(352);
	decoded(343)	<=	coded(353);
	decoded(344)	<=	coded(354);
	decoded(345)	<=	coded(355);
	decoded(346)	<=	coded(356);
	decoded(347)	<=	coded(357);
	decoded(348)	<=	coded(358);
	decoded(349)	<=	coded(359);
	decoded(350)	<=	coded(360);
	decoded(351)	<=	coded(361);
	decoded(352)	<=	coded(362);
	decoded(353)	<=	coded(363);
	decoded(354)	<=	coded(364);
	decoded(355)	<=	coded(365);
	decoded(356)	<=	coded(366);
	decoded(357)	<=	coded(367);
	decoded(358)	<=	coded(368);
	decoded(359)	<=	coded(369);
	decoded(360)	<=	coded(370);
	decoded(361)	<=	coded(371);
	decoded(362)	<=	coded(372);
	decoded(363)	<=	coded(373);
	decoded(364)	<=	coded(374);
	decoded(365)	<=	coded(375);
	decoded(366)	<=	coded(376);
	decoded(367)	<=	coded(377);
	decoded(368)	<=	coded(378);
	decoded(369)	<=	coded(379);
	decoded(370)	<=	coded(380);
	decoded(371)	<=	coded(381);
	decoded(372)	<=	coded(382);
	decoded(373)	<=	coded(383);
	decoded(374)	<=	coded(384);
	decoded(375)	<=	coded(385);
	decoded(376)	<=	coded(386);
	decoded(377)	<=	coded(387);
	decoded(378)	<=	coded(388);
	decoded(379)	<=	coded(389);
	decoded(380)	<=	coded(390);
	decoded(381)	<=	coded(391);
	decoded(382)	<=	coded(392);
	decoded(383)	<=	coded(393);
	decoded(384)	<=	coded(394);
	decoded(385)	<=	coded(395);
	decoded(386)	<=	coded(396);
	decoded(387)	<=	coded(397);
	decoded(388)	<=	coded(398);
	decoded(389)	<=	coded(399);
	decoded(390)	<=	coded(400);
	decoded(391)	<=	coded(401);
	decoded(392)	<=	coded(402);
	decoded(393)	<=	coded(403);
	decoded(394)	<=	coded(404);
	decoded(395)	<=	coded(405);
	decoded(396)	<=	coded(406);
	decoded(397)	<=	coded(407);
	decoded(398)	<=	coded(408);
	decoded(399)	<=	coded(409);
	decoded(400)	<=	coded(410);
	decoded(401)	<=	coded(411);
	decoded(402)	<=	coded(412);
	decoded(403)	<=	coded(413);
	decoded(404)	<=	coded(414);
	decoded(405)	<=	coded(415);
	decoded(406)	<=	coded(416);
	decoded(407)	<=	coded(417);
	decoded(408)	<=	coded(418);
	decoded(409)	<=	coded(419);
	decoded(410)	<=	coded(420);
	decoded(411)	<=	coded(421);
	decoded(412)	<=	coded(422);
	decoded(413)	<=	coded(423);
	decoded(414)	<=	coded(424);
	decoded(415)	<=	coded(425);
	decoded(416)	<=	coded(426);
	decoded(417)	<=	coded(427);
	decoded(418)	<=	coded(428);
	decoded(419)	<=	coded(429);
	decoded(420)	<=	coded(430);
	decoded(421)	<=	coded(431);
	decoded(422)	<=	coded(432);
	decoded(423)	<=	coded(433);
	decoded(424)	<=	coded(434);
	decoded(425)	<=	coded(435);
	decoded(426)	<=	coded(436);
	decoded(427)	<=	coded(437);
	decoded(428)	<=	coded(438);
	decoded(429)	<=	coded(439);
	decoded(430)	<=	coded(440);
	decoded(431)	<=	coded(441);
	decoded(432)	<=	coded(442);
	decoded(433)	<=	coded(443);
	decoded(434)	<=	coded(444);
	decoded(435)	<=	coded(445);
	decoded(436)	<=	coded(446);
	decoded(437)	<=	coded(447);
	decoded(438)	<=	coded(448);
	decoded(439)	<=	coded(449);
	decoded(440)	<=	coded(450);
	decoded(441)	<=	coded(451);
	decoded(442)	<=	coded(452);
	decoded(443)	<=	coded(453);
	decoded(444)	<=	coded(454);
	decoded(445)	<=	coded(455);
	decoded(446)	<=	coded(456);
	decoded(447)	<=	coded(457);
	decoded(448)	<=	coded(458);
	decoded(449)	<=	coded(459);
	decoded(450)	<=	coded(460);
	decoded(451)	<=	coded(461);
	decoded(452)	<=	coded(462);
	decoded(453)	<=	coded(463);
	decoded(454)	<=	coded(464);
	decoded(455)	<=	coded(465);
	decoded(456)	<=	coded(466);
	decoded(457)	<=	coded(467);
	decoded(458)	<=	coded(468);
	decoded(459)	<=	coded(469);
	decoded(460)	<=	coded(470);
	decoded(461)	<=	coded(471);
	decoded(462)	<=	coded(472);
	decoded(463)	<=	coded(473);
	decoded(464)	<=	coded(474);
	decoded(465)	<=	coded(475);
	decoded(466)	<=	coded(476);
	decoded(467)	<=	coded(477);
	decoded(468)	<=	coded(478);
	decoded(469)	<=	coded(479);
	decoded(470)	<=	coded(480);
	decoded(471)	<=	coded(481);
	decoded(472)	<=	coded(482);
	decoded(473)	<=	coded(483);
	decoded(474)	<=	coded(484);
	decoded(475)	<=	coded(485);
	decoded(476)	<=	coded(486);
	decoded(477)	<=	coded(487);
	decoded(478)	<=	coded(488);
	decoded(479)	<=	coded(489);
	decoded(480)	<=	coded(490);
	decoded(481)	<=	coded(491);
	decoded(482)	<=	coded(492);
	decoded(483)	<=	coded(493);
	decoded(484)	<=	coded(494);
	decoded(485)	<=	coded(495);
	decoded(486)	<=	coded(496);
	decoded(487)	<=	coded(497);
	decoded(488)	<=	coded(498);
	decoded(489)	<=	coded(499);
	decoded(490)	<=	coded(500);
	decoded(491)	<=	coded(501);
	decoded(492)	<=	coded(502);
	decoded(493)	<=	coded(503);
	decoded(494)	<=	coded(504);
	decoded(495)	<=	coded(505);

END;
END PACKAGE BODY;
