import { Question, QuestionType } from '../types';

const { MATHS, VERBAL, NON_VERBAL } = QuestionType;

/**
 * Target 334 question bank — original GL-style questions.
 * MATHS: 35 (15 core + 20 advanced ratio / multi-step word problems)
 * VERBAL: 15 · NON_VERBAL: 12
 * Every explanation is Markdown and written as a step-by-step tutor walkthrough.
 */
export const mockQuestions: Question[] = [
  /* ============================= MATHEMATICS — CORE ============================= */
  {
    id: 'M1',
    type: MATHS,
    topic: 'Fractions',
    prompt: 'What is ¾ of 96?',
    options: ['64', '68', '72', '76', '78'],
    answerIndex: 2,
    explanation:
      '**Step 1:** To find ¾ of a number, first find one quarter by dividing by 4: 96 ÷ 4 = 24.\n\n**Step 2:** Three quarters is three of those parts: 24 × 3 = 72.\n\n**Check:** 72 is a bit less than 96 but more than half of it (48) — exactly what we expect for ¾. The answer is **72**.',
  },
  {
    id: 'M2',
    type: MATHS,
    topic: 'Word Problems (Money)',
    prompt:
      'Sara buys 3 pencils costing 45p each and one rubber costing 60p. She pays with a £2 coin. How much change does she receive?',
    options: ['5p', '15p', '25p', '35p', '45p'],
    answerIndex: 0,
    explanation:
      '**Step 1:** Cost of the pencils: 3 × 45p = 135p.\n\n**Step 2:** Add the rubber: 135p + 60p = 195p (that is £1.95).\n\n**Step 3:** She pays with £2.00 = 200p. Change = 200p − 195p = **5p**.\n\n**Exam tip:** Turn everything into pence first — mixing pounds and pence is the number one cause of silly mistakes in money questions.',
  },
  {
    id: 'M3',
    type: MATHS,
    topic: 'Ratio',
    prompt: '40 sweets are shared between Amy and Ben in the ratio 3 : 5. How many sweets does Amy get?',
    options: ['12', '15', '18', '20', '25'],
    answerIndex: 1,
    explanation:
      '**Step 1:** Add the ratio parts: 3 + 5 = 8 parts in total.\n\n**Step 2:** Find the value of one part: 40 ÷ 8 = 5 sweets per part.\n\n**Step 3:** Amy has 3 parts: 3 × 5 = **15 sweets**.\n\n**Check:** Ben gets 5 × 5 = 25, and 15 + 25 = 40. ✔',
  },
  {
    id: 'M4',
    type: MATHS,
    topic: 'Percentages',
    prompt: 'What is 15% of 240?',
    options: ['24', '30', '36', '42', '48'],
    answerIndex: 2,
    explanation:
      '**Step 1:** Break 15% into easy chunks: 15% = 10% + 5%.\n\n**Step 2:** 10% of 240 = 24 (just divide by 10).\n\n**Step 3:** 5% is half of 10%, so 5% of 240 = 12.\n\n**Step 4:** Add them: 24 + 12 = **36**.\n\n**Exam tip:** The 10% + 5% trick handles almost every percentage question quickly — no long multiplication needed.',
  },
  {
    id: 'M5',
    type: MATHS,
    topic: 'Fractions',
    prompt: 'What is ⅔ + ⅙?',
    options: ['3⁄9', '1⁄2', '2⁄3', '5⁄6', '1'],
    answerIndex: 3,
    explanation:
      '**Step 1:** To add fractions we need the same denominator. The denominators are 3 and 6, and 6 works for both.\n\n**Step 2:** Convert ⅔ into sixths: multiply top and bottom by 2, giving 4⁄6.\n\n**Step 3:** Now add: 4⁄6 + 1⁄6 = **5⁄6**.\n\n**Check:** 5⁄6 cannot be simplified (5 and 6 share no common factor), so we are done.',
  },
  {
    id: 'M6',
    type: MATHS,
    topic: 'Time',
    prompt:
      'A train leaves Manchester at 09:45. The journey takes 1 hour and 50 minutes. What time does it arrive?',
    options: ['11:25', '11:30', '11:35', '11:40', '11:45'],
    answerIndex: 2,
    explanation:
      '**Step 1:** Add the whole hour first: 09:45 + 1 hour = 10:45.\n\n**Step 2:** Now add the 50 minutes in friendly jumps. From 10:45, add 15 minutes to reach 11:00.\n\n**Step 3:** That leaves 50 − 15 = 35 minutes still to add: 11:00 + 35 minutes = **11:35**.\n\n**Exam tip:** Always "bridge" to the next o\'clock — it stops you accidentally writing times like 10:95!',
  },
  {
    id: 'M7',
    type: MATHS,
    topic: 'Fractions',
    prompt: 'Simplify the fraction 48⁄60 to its lowest terms.',
    options: ['3⁄4', '4⁄5', '5⁄6', '6⁄7', '7⁄8'],
    answerIndex: 1,
    explanation:
      '**Step 1:** Find a number that divides into both 48 and 60. Both are in the 12 times table: 48 = 12 × 4 and 60 = 12 × 5.\n\n**Step 2:** Divide top and bottom by 12: 48 ÷ 12 = 4 and 60 ÷ 12 = 5.\n\n**Step 3:** So 48⁄60 = **4⁄5**.\n\n**Check:** 4 and 5 share no common factor other than 1, so the fraction is fully simplified.',
  },
  {
    id: 'M8',
    type: MATHS,
    topic: 'Percentages (Reverse)',
    prompt: 'A book costs £8 in a sale after a 20% discount. What was the original price?',
    options: ['£9.60', '£10.00', '£10.40', '£12.00', '£16.00'],
    answerIndex: 1,
    explanation:
      '**Step 1:** After 20% off, the sale price is 80% of the original (100% − 20% = 80%).\n\n**Step 2:** So 80% of the original price = £8.\n\n**Step 3:** Find 10% first: if 80% = £8, then 10% = £8 ÷ 8 = £1.\n\n**Step 4:** The full 100% = £1 × 10 = **£10**.\n\n**Common trap:** Do NOT add 20% of £8 (£1.60) to get £9.60 — the 20% was taken off the *original* price, not the sale price!',
  },
  {
    id: 'M9',
    type: MATHS,
    topic: 'Ratio',
    prompt:
      'In a school club the ratio of boys to girls is 4 : 3. There are 28 boys. How many girls are there?',
    options: ['12', '18', '21', '24', '28'],
    answerIndex: 2,
    explanation:
      '**Step 1:** The boys represent 4 parts of the ratio, and 4 parts = 28 children.\n\n**Step 2:** One part = 28 ÷ 4 = 7 children.\n\n**Step 3:** Girls are 3 parts: 3 × 7 = **21 girls**.\n\n**Check:** 28 : 21 simplifies back to 4 : 3 (divide both by 7). ✔',
  },
  {
    id: 'M10',
    type: MATHS,
    topic: 'Decimals & Fractions',
    prompt: 'Which fraction is equal to 0.35?',
    options: ['3⁄5', '7⁄20', '35⁄10', '5⁄7', '7⁄2'],
    answerIndex: 1,
    explanation:
      '**Step 1:** 0.35 means 35 hundredths, so write it as 35⁄100.\n\n**Step 2:** Simplify. Both 35 and 100 divide by 5: 35 ÷ 5 = 7 and 100 ÷ 5 = 20.\n\n**Step 3:** So 0.35 = **7⁄20**.\n\n**Check:** 7 ÷ 20 = 0.35. ✔',
  },
  {
    id: 'M11',
    type: MATHS,
    topic: 'Shape & Measure',
    prompt:
      'A rectangle has a length of 12 cm. Its width is half of its length. What is the perimeter of the rectangle?',
    options: ['18 cm', '24 cm', '30 cm', '36 cm', '72 cm'],
    answerIndex: 3,
    explanation:
      '**Step 1:** Work out the width: half of 12 cm = 6 cm.\n\n**Step 2:** Perimeter means the distance all the way around: two lengths and two widths.\n\n**Step 3:** Perimeter = 2 × (12 + 6) = 2 × 18 = **36 cm**.\n\n**Common trap:** 72 is the *area* (12 × 6) — the examiners love to include the area as a wrong option!',
  },
  {
    id: 'M12',
    type: MATHS,
    topic: 'Averages',
    prompt:
      'Four children scored 12, 15, 18 and 15 in a spelling test. What was their mean (average) score?',
    options: ['13', '14', '15', '16', '17'],
    answerIndex: 2,
    explanation:
      '**Step 1:** The mean = total of all scores ÷ how many scores there are.\n\n**Step 2:** Total: 12 + 15 + 18 + 15 = 60.\n\n**Step 3:** There are 4 scores, so mean = 60 ÷ 4 = **15**.\n\n**Sense check:** The mean must sit between the smallest (12) and largest (18) score — 15 does. ✔',
  },
  {
    id: 'M13',
    type: MATHS,
    topic: 'Fractions (Reverse)',
    prompt: '⅝ of a number is 40. What is the number?',
    options: ['25', '48', '56', '64', '72'],
    answerIndex: 3,
    explanation:
      '**Step 1:** If 5 eighths of the number equal 40, then one eighth = 40 ÷ 5 = 8.\n\n**Step 2:** The whole number is 8 eighths: 8 × 8 = **64**.\n\n**Check:** ⅝ of 64 → 64 ÷ 8 = 8, then 8 × 5 = 40. ✔\n\n**Exam tip:** "Fraction of a mystery number" questions always work the same way: divide by the top, multiply by the bottom.',
  },
  {
    id: 'M14',
    type: MATHS,
    topic: 'Word Problems (Measure)',
    prompt:
      'A baker has 4.2 kg of flour. Each loaf of bread needs 350 g of flour. How many loaves can the baker make?',
    options: ['10', '11', '12', '13', '14'],
    answerIndex: 2,
    explanation:
      '**Step 1:** Make the units match: 4.2 kg = 4200 g.\n\n**Step 2:** Divide the total flour by the flour per loaf: 4200 ÷ 350.\n\n**Step 3:** Make it friendlier: 350 × 10 = 3500, and 4200 − 3500 = 700, which is 2 more loaves (350 × 2). So 10 + 2 = **12 loaves**.\n\n**Exam tip:** Always convert kg to g (or £ to p) before dividing — mixed units are a classic trap.',
  },
  {
    id: 'M15',
    type: MATHS,
    topic: 'Word Problems (Money)',
    prompt:
      'Cinema tickets cost £6.50 for an adult and £4.00 for a child. How much does it cost in total for 2 adults and 3 children?',
    options: ['£23.00', '£24.00', '£25.00', '£26.00', '£27.00'],
    answerIndex: 2,
    explanation:
      '**Step 1:** Adults: 2 × £6.50 = £13.00.\n\n**Step 2:** Children: 3 × £4.00 = £12.00.\n\n**Step 3:** Total: £13 + £12 = **£25.00**.\n\n**Exam tip:** In multi-step money questions, write down each sub-total before adding — doing it all in your head is where marks get lost.',
  },

  /* ================== MATHEMATICS — ADVANCED RATIO & MULTI-STEP ================== */
  {
    id: 'AM1',
    type: MATHS,
    topic: 'Ratio (Three-Way Share)',
    prompt:
      '£120 is shared between three sisters in the ratio 2 : 3 : 5. How much does the sister with the smallest share receive?',
    options: ['£24', '£36', '£48', '£60', '£12'],
    answerIndex: 0,
    explanation:
      '**Step 1:** Add all the ratio parts: 2 + 3 + 5 = 10 parts.\n\n**Step 2:** One part = £120 ÷ 10 = £12.\n\n**Step 3:** The smallest share is 2 parts: 2 × £12 = **£24**.\n\n**Check:** The three shares are £24, £36 and £60, and £24 + £36 + £60 = £120. ✔\n\n**Exam tip:** With three-way ratios, ALWAYS total the parts first — then every share is just "parts × value of one part".',
  },
  {
    id: 'AM2',
    type: MATHS,
    topic: 'Ratio (Recipes)',
    prompt:
      'A cake recipe uses flour and sugar in the ratio 5 : 2. If a baker uses 350 g of flour, how much sugar is needed?',
    options: ['100 g', '120 g', '140 g', '160 g', '175 g'],
    answerIndex: 2,
    explanation:
      '**Step 1:** Flour is 5 parts, and 5 parts = 350 g.\n\n**Step 2:** One part = 350 ÷ 5 = 70 g.\n\n**Step 3:** Sugar is 2 parts: 2 × 70 = **140 g**.\n\n**Check:** Flour : sugar = 350 : 140. Divide both by 70 → 5 : 2. ✔\n\n**Exam tip:** In recipe questions, first ask "which ingredient do I already know?" — that ingredient tells you the value of one part.',
  },
  {
    id: 'AM3',
    type: MATHS,
    topic: 'Ratio (Finding the Total)',
    prompt:
      'The ratio of red counters to blue counters in a bag is 3 : 4. There are 12 red counters. How many counters are in the bag altogether?',
    options: ['16', '21', '24', '28', '36'],
    answerIndex: 3,
    explanation:
      '**Step 1:** Red is 3 parts, and 3 parts = 12 counters, so one part = 12 ÷ 3 = 4 counters.\n\n**Step 2:** Blue is 4 parts: 4 × 4 = 16 counters.\n\n**Step 3:** Total = red + blue = 12 + 16 = **28 counters**.\n\n**Common trap:** 16 is only the number of BLUE counters — read carefully whether the question wants one colour or the whole bag!',
  },
  {
    id: 'AM4',
    type: MATHS,
    topic: 'Scale & Maps',
    prompt:
      'On a map, 1 cm represents 4 km in real life. Two towns are 3.5 cm apart on the map. What is the real distance between them?',
    options: ['7.5 km', '12 km', '14 km', '16 km', '17.5 km'],
    answerIndex: 2,
    explanation:
      '**Step 1:** Every centimetre on the map is worth 4 km, so multiply: 3.5 × 4.\n\n**Step 2:** Split the 3.5 to make it easy: 3 × 4 = 12 and 0.5 × 4 = 2.\n\n**Step 3:** Add them: 12 + 2 = **14 km**.\n\n**Exam tip:** Map-scale questions are secretly multiplication questions. Write the scale as "1 cm → 4 km" and the arrows keep your thinking straight.',
  },
  {
    id: 'AM5',
    type: MATHS,
    topic: 'Speed & Distance',
    prompt: 'A cyclist travels 24 km in 1½ hours. What is her average speed in km per hour?',
    options: ['12 km/h', '14 km/h', '16 km/h', '18 km/h', '36 km/h'],
    answerIndex: 2,
    explanation:
      '**Step 1:** Speed = distance ÷ time, so we need 24 ÷ 1½.\n\n**Step 2:** Think in half-hours: 1½ hours is 3 half-hours, so in each half-hour she covers 24 ÷ 3 = 8 km.\n\n**Step 3:** A full hour is two half-hours: 8 × 2 = **16 km/h**.\n\n**Check:** At 16 km/h — one hour gives 16 km, the extra half-hour gives 8 km, and 16 + 8 = 24 km. ✔',
  },
  {
    id: 'AM6',
    type: MATHS,
    topic: 'Multi-Step Word Problem',
    prompt:
      'A school trip coach costs £360, shared equally between 24 children. Each child also pays £5 for a museum ticket. How much does each child pay in total?',
    options: ['£15', '£18', '£20', '£22', '£25'],
    answerIndex: 2,
    explanation:
      '**Step 1:** Share the coach cost: £360 ÷ 24. Since 24 × 15 = 360, each child pays £15 for the coach.\n\n**Step 2:** Add the museum ticket: £15 + £5 = **£20**.\n\n**Exam tip:** For a division like 360 ÷ 24, try "chunking with easy numbers": 24 × 10 = 240, leaving 120, and 24 × 5 = 120 — so the answer is 10 + 5 = 15.',
  },
  {
    id: 'AM7',
    type: MATHS,
    topic: 'Ratio (Mixed Units)',
    prompt: 'Write the ratio 45 minutes : 2 hours in its simplest form.',
    options: ['45 : 2', '3 : 8', '8 : 3', '9 : 24', '1 : 3'],
    answerIndex: 1,
    explanation:
      '**Step 1:** A ratio can only be simplified when both sides use the SAME units. Convert 2 hours into minutes: 2 × 60 = 120 minutes.\n\n**Step 2:** The ratio is now 45 : 120.\n\n**Step 3:** Divide both sides by their biggest common factor, 15: 45 ÷ 15 = 3 and 120 ÷ 15 = 8, giving **3 : 8**.\n\n**Common trap:** 45 : 2 keeps the mixed units and 9 : 24 is not fully simplified (both still divide by 3) — examiners include both on purpose!',
  },
  {
    id: 'AM8',
    type: MATHS,
    topic: 'Ratio (Given the Difference)',
    prompt:
      'Tom and Sam share football stickers in the ratio 5 : 3. Tom has 12 more stickers than Sam. How many stickers does Sam have?',
    options: ['12', '15', '18', '24', '30'],
    answerIndex: 2,
    explanation:
      '**Step 1:** The DIFFERENCE between their shares is 5 − 3 = 2 parts.\n\n**Step 2:** That difference equals 12 stickers, so one part = 12 ÷ 2 = 6 stickers.\n\n**Step 3:** Sam has 3 parts: 3 × 6 = **18 stickers**.\n\n**Check:** Tom has 5 × 6 = 30, which is indeed 12 more than 18. ✔\n\n**Exam tip:** This is the hardest ratio twist: when you are told the DIFFERENCE (not the total), divide the difference by the difference in parts.',
  },
  {
    id: 'AM9',
    type: MATHS,
    topic: 'Proportion (Scaling)',
    prompt: 'A recipe for 4 people needs 300 g of pasta. How much pasta is needed for 10 people?',
    options: ['600 g', '700 g', '750 g', '800 g', '900 g'],
    answerIndex: 2,
    explanation:
      '**Step 1:** Find the amount for ONE person first: 300 ÷ 4 = 75 g per person.\n\n**Step 2:** Scale up to 10 people: 75 × 10 = **750 g**.\n\n**Exam tip:** This "unitary method" (find one, then scale) works for every proportion question — recipes, prices, paint mixing, everything. It is slower but never goes wrong.',
  },
  {
    id: 'AM10',
    type: MATHS,
    topic: 'Multi-Step Word Problem (Money)',
    prompt:
      'Emma is saving for a bike that costs £85. She already has £22.50 and saves £2.50 every week. How many weeks will it take her to afford the bike?',
    options: ['20', '23', '25', '27', '30'],
    answerIndex: 2,
    explanation:
      '**Step 1:** Work out how much she still needs: £85 − £22.50 = £62.50.\n\n**Step 2:** Divide by her weekly saving: £62.50 ÷ £2.50.\n\n**Step 3:** Make it whole numbers by multiplying both by 100: 6250 ÷ 250 = 25. So it takes **25 weeks**.\n\n**Check:** 25 weeks × £2.50 = £62.50, plus her £22.50 = exactly £85. ✔\n\n**Exam tip:** Dividing by a decimal? Multiply BOTH numbers by 10 or 100 first so you divide with whole numbers.',
  },
  {
    id: 'AM11',
    type: MATHS,
    topic: 'Ratio (Angles)',
    prompt:
      'The three angles of a triangle are in the ratio 2 : 3 : 4. What is the size of the largest angle?',
    options: ['40°', '60°', '80°', '90°', '100°'],
    answerIndex: 2,
    explanation:
      '**Step 1:** Recall the fact the question does not tell you: angles in a triangle add up to 180°.\n\n**Step 2:** Total ratio parts: 2 + 3 + 4 = 9, so one part = 180 ÷ 9 = 20°.\n\n**Step 3:** The largest angle is 4 parts: 4 × 20 = **80°**.\n\n**Check:** The angles are 40°, 60° and 80°, and 40 + 60 + 80 = 180. ✔\n\n**Exam tip:** Ratio questions often hide a maths fact you must supply yourself — angle sums, hours in a day, pence in a pound.',
  },
  {
    id: 'AM12',
    type: MATHS,
    topic: 'Inverse Proportion',
    prompt:
      '3 identical taps fill a paddling pool in 12 minutes. How long would 4 of the same taps take to fill the same pool?',
    options: ['8 minutes', '9 minutes', '10 minutes', '15 minutes', '16 minutes'],
    answerIndex: 1,
    explanation:
      '**Step 1:** Careful — MORE taps means LESS time. This is inverse proportion, not ordinary scaling.\n\n**Step 2:** Work out the total "tap-minutes" of work: 3 taps × 12 minutes = 36 tap-minutes to fill the pool.\n\n**Step 3:** Share that work between 4 taps: 36 ÷ 4 = **9 minutes**.\n\n**Common trap:** The tempting "scale up" answer 16 (12 × 4 ÷ 3) is correct arithmetic for the WRONG direction — always pause and ask "should my answer be bigger or smaller?"',
  },
  {
    id: 'AM13',
    type: MATHS,
    topic: 'Best Buy (Unit Cost)',
    prompt:
      'A shop sells pencils in packs of 6 for £1.20 or packs of 10 for £1.80. Which pack is better value, and by how much per pencil?',
    options: [
      'The 6-pack, by 2p per pencil',
      'The 10-pack, by 2p per pencil',
      'They are the same value',
      'The 10-pack, by 5p per pencil',
      'The 6-pack, by 5p per pencil',
    ],
    answerIndex: 1,
    explanation:
      '**Step 1:** Find the cost of ONE pencil in each pack. 6-pack: 120p ÷ 6 = 20p each.\n\n**Step 2:** 10-pack: 180p ÷ 10 = 18p each.\n\n**Step 3:** Compare: 20p − 18p = 2p, so **the 10-pack is better value by 2p per pencil**.\n\n**Exam tip:** "Best buy" questions are always solved the same way — find the price of ONE item (or 100 g) in each offer, then compare.',
  },
  {
    id: 'AM14',
    type: MATHS,
    topic: 'Fractions → Ratio',
    prompt: 'In a class of 32 children, ¾ are girls. What is the ratio of girls to boys in its simplest form?',
    options: ['3 : 1', '1 : 3', '4 : 1', '3 : 4', '2 : 1'],
    answerIndex: 0,
    explanation:
      '**Step 1:** Count the girls: ¾ of 32 = 24 girls.\n\n**Step 2:** The rest are boys: 32 − 24 = 8 boys.\n\n**Step 3:** Ratio of girls : boys = 24 : 8. Divide both by 8 → **3 : 1**.\n\n**Common trap:** 3 : 4 is the fraction ¾ dressed up as a ratio — but ¾ compares girls to the WHOLE class, while the ratio compares girls to BOYS. Different things!',
  },
  {
    id: 'AM15',
    type: MATHS,
    topic: 'Multi-Step Word Problem',
    prompt:
      'A plumber charges a £40 call-out fee plus £25 for every hour of work. A job costs £140 in total. How many hours did the job take?',
    options: ['2 hours', '3 hours', '4 hours', '5 hours', '6 hours'],
    answerIndex: 2,
    explanation:
      '**Step 1:** Remove the fixed call-out fee first: £140 − £40 = £100 was for the hourly work.\n\n**Step 2:** Divide by the hourly rate: £100 ÷ £25 = **4 hours**.\n\n**Check:** 4 × £25 = £100, plus £40 call-out = £140. ✔\n\n**Exam tip:** "Fixed charge plus rate" problems always work backwards in the same order: subtract the fixed part, THEN divide by the rate.',
  },
  {
    id: 'AM16',
    type: MATHS,
    topic: 'Ratio (Mixtures)',
    prompt:
      'Orange drink is made by mixing squash and water in the ratio 1 : 6. How much squash is needed to make 1.4 litres of drink?',
    options: ['140 ml', '200 ml', '233 ml', '280 ml', '700 ml'],
    answerIndex: 1,
    explanation:
      '**Step 1:** The whole drink is 1 + 6 = 7 parts.\n\n**Step 2:** Convert to millilitres to keep the numbers friendly: 1.4 litres = 1400 ml. One part = 1400 ÷ 7 = 200 ml.\n\n**Step 3:** Squash is 1 part = **200 ml**.\n\n**Check:** Water would be 6 × 200 = 1200 ml, and 200 + 1200 = 1400 ml. ✔\n\n**Common trap:** Dividing by 6 instead of 7 — the 1.4 litres is the FINISHED drink (squash AND water together), so you must share it into all 7 parts.',
  },
  {
    id: 'AM17',
    type: MATHS,
    topic: 'Percentages + Ratio Combo',
    prompt:
      'A jar holds 60 sweets. 25% of them are toffees. The rest are mints and chews in the ratio 2 : 1. How many mints are there?',
    options: ['15', '20', '30', '35', '45'],
    answerIndex: 2,
    explanation:
      '**Step 1:** Count the toffees: 25% of 60 = 60 ÷ 4 = 15 toffees.\n\n**Step 2:** The rest: 60 − 15 = 45 sweets are mints and chews.\n\n**Step 3:** Share 45 in the ratio 2 : 1. Total parts = 3, so one part = 45 ÷ 3 = 15. Mints are 2 parts: 2 × 15 = **30 mints**.\n\n**Exam tip:** Advanced GL questions chain two skills together (here percentage THEN ratio). Do them one at a time and write down the in-between number — never juggle both in your head.',
  },
  {
    id: 'AM18',
    type: MATHS,
    topic: 'Word Problem (Ages)',
    prompt: 'Amy is three times as old as her brother Ben. Their ages add up to 48. How old is Ben?',
    options: ['8', '12', '16', '24', '36'],
    answerIndex: 1,
    explanation:
      '**Step 1:** Turn the words into a ratio: Amy : Ben = 3 : 1.\n\n**Step 2:** Total parts = 3 + 1 = 4, and 4 parts = 48 years, so one part = 48 ÷ 4 = 12.\n\n**Step 3:** Ben is 1 part = **12 years old**.\n\n**Check:** Amy is 3 × 12 = 36, and 36 + 12 = 48. ✔\n\n**Exam tip:** "Three times as old" problems ARE ratio problems in disguise — rewrite the sentence as a ratio and the method becomes automatic.',
  },
  {
    id: 'AM19',
    type: MATHS,
    topic: 'Ratio (Shape & Perimeter)',
    prompt:
      'The length and width of a rectangle are in the ratio 5 : 2. The perimeter of the rectangle is 42 cm. What is the width?',
    options: ['5 cm', '6 cm', '9 cm', '12 cm', '15 cm'],
    answerIndex: 1,
    explanation:
      '**Step 1:** Perimeter = 2 × (length + width). Length + width together make 5 + 2 = 7 parts, so the perimeter is 2 × 7 = 14 parts.\n\n**Step 2:** 14 parts = 42 cm, so one part = 42 ÷ 14 = 3 cm.\n\n**Step 3:** Width = 2 parts = 2 × 3 = **6 cm**.\n\n**Check:** Length = 5 × 3 = 15 cm. Perimeter = 2 × (15 + 6) = 2 × 21 = 42 cm. ✔\n\n**Exam tip:** For ratio + perimeter, remember the perimeter uses each side TWICE — double the ratio total before dividing.',
  },
  {
    id: 'AM20',
    type: MATHS,
    topic: 'Best Buy (Per 100 g)',
    prompt:
      'A 500 g box of cereal costs £1.60. A 750 g box of the same cereal costs £2.10. How much cheaper per 100 g is the bigger box?',
    options: ['2p', '4p', '6p', '8p', '10p'],
    answerIndex: 1,
    explanation:
      '**Step 1:** Small box per 100 g: £1.60 = 160p for 5 lots of 100 g, so 160 ÷ 5 = 32p per 100 g.\n\n**Step 2:** Big box per 100 g: £2.10 = 210p for 7.5 lots of 100 g... easier: 750 g is 7½ lots, so try 210 ÷ 7.5 = 28p per 100 g. (Check: 28 × 7.5 = 210. ✔)\n\n**Step 3:** Difference: 32 − 28 = **4p cheaper per 100 g**.\n\n**Exam tip:** Comparing per 100 g keeps numbers small. If a division looks ugly (like ÷ 7.5), double both numbers first: 420 ÷ 15 = 28.',
  },

  /* ============================= VERBAL REASONING ============================= */
  {
    id: 'V1',
    type: VERBAL,
    topic: 'Letter Codes',
    prompt: 'In a secret code, CAT is written as DBU. Using the same code, how is DOG written?',
    options: ['EPH', 'EPI', 'FPH', 'EQH', 'DPH'],
    answerIndex: 0,
    explanation:
      '**Step 1:** Crack the code by comparing letters: C→D, A→B, T→U. Every letter moves forward **one place** in the alphabet (+1).\n\n**Step 2:** Apply +1 to DOG: D→E, O→P, G→H.\n\n**Step 3:** The answer is **EPH**.\n\n**Exam tip:** Write the alphabet across the top of your rough paper at the start of the test — counting on fingers causes mistakes under time pressure.',
  },
  {
    id: 'V2',
    type: VERBAL,
    topic: 'Letter Sequences',
    prompt: 'Find the next pair of letters in the sequence:  AZ,  BY,  CX,  ( ? )',
    options: ['DW', 'DV', 'EW', 'DX', 'EV'],
    answerIndex: 0,
    explanation:
      '**Step 1:** Look at the first letter of each pair: A, B, C … it moves forward one place each time, so next is **D**.\n\n**Step 2:** Look at the second letter: Z, Y, X … it moves backwards one place each time, so next is **W**.\n\n**Step 3:** Put them together: **DW**.\n\n**Pattern spot:** These are "mirror pairs" — A pairs with Z, B with Y, C with X, D with W: each pair sits the same distance from opposite ends of the alphabet.',
  },
  {
    id: 'V3',
    type: VERBAL,
    topic: 'Synonyms',
    prompt: 'Choose the word closest in meaning to ABUNDANT.',
    options: ['scarce', 'plentiful', 'tidy', 'distant', 'hollow'],
    answerIndex: 1,
    explanation:
      '**Step 1:** ABUNDANT means existing in very large amounts — for example, "abundant rainfall" means lots and lots of rain.\n\n**Step 2:** Test each option: *scarce* is the opposite (very little); *tidy*, *distant* and *hollow* have nothing to do with quantity.\n\n**Step 3:** *Plentiful* also means "in large amounts", so **plentiful** is the answer.\n\n**Exam tip:** If unsure, put each option into a sentence in place of the original word and see which keeps the meaning.',
  },
  {
    id: 'V4',
    type: VERBAL,
    topic: 'Antonyms',
    prompt: 'Choose the word most opposite in meaning to EXPAND.',
    options: ['enlarge', 'stretch', 'contract', 'explode', 'extend'],
    answerIndex: 2,
    explanation:
      '**Step 1:** EXPAND means to get bigger or take up more space.\n\n**Step 2:** Watch out — *enlarge*, *stretch* and *extend* all mean nearly the SAME as expand. They are traps for pupils reading too quickly.\n\n**Step 3:** To *contract* means to get smaller or shrink — the true opposite. The answer is **contract**.\n\n**Exam tip:** Antonym questions hide synonyms in the options on purpose. Re-read the question to check whether it asks for SAME or OPPOSITE.',
  },
  {
    id: 'V5',
    type: VERBAL,
    topic: 'Letter Codes (Decode)',
    prompt: 'In a certain code, BIRD is written as CJSE. What word does the code DPX stand for?',
    options: ['COW', 'DOG', 'CAT', 'EMU', 'FOX'],
    answerIndex: 0,
    explanation:
      '**Step 1:** Crack the code: B→C, I→J, R→S, D→E. Each letter moves forward one place (+1) to make the code.\n\n**Step 2:** DPX is already in code, so to decode we go **backwards** one place (−1): D→C, P→O, X→W.\n\n**Step 3:** The hidden word is **COW**.\n\n**Common trap:** Decoding means reversing the rule. Pupils who apply +1 again get EQY — not a word, which is your clue to switch direction!',
  },
  {
    id: 'V6',
    type: VERBAL,
    topic: 'Hidden Words',
    prompt:
      'A word of five letters is hidden across the words of this sentence: "She tried her best on every question." Which word is hidden?',
    options: ['STONE', 'TONES', 'BEAST', 'RIDES', 'NOTES'],
    answerIndex: 0,
    explanation:
      '**Step 1:** Hidden-word questions join the END of one word to the START of the next. Slide along the sentence checking each join.\n\n**Step 2:** Look at "be**st on e**very": take ST (end of *best*) + ON (all of *on*) + E (start of *every*).\n\n**Step 3:** S-T-O-N-E spells **STONE**.\n\n**Exam tip:** Scan the joins between words methodically from left to right — the hidden word almost never sits inside a single word.',
  },
  {
    id: 'V7',
    type: VERBAL,
    topic: 'Letter Sequences',
    prompt: 'Find the next pair of letters in the sequence:  CD,  FG,  IJ,  LM,  ( ? )',
    options: ['NO', 'OP', 'PQ', 'MN', 'OQ'],
    answerIndex: 1,
    explanation:
      '**Step 1:** Look at the first letters: C, F, I, L. Each jumps forward 3 places (C+3=F, F+3=I, I+3=L). So next is L+3 = **O**.\n\n**Step 2:** Each pair is two neighbouring letters (C&D, F&G…), so the partner of O is **P**.\n\n**Step 3:** The answer is **OP**.\n\n**Exam tip:** Solve the first letters and second letters as two separate mini-sequences — never try to see the whole pattern at once.',
  },
  {
    id: 'V8',
    type: VERBAL,
    topic: 'Word–Number Codes',
    prompt: 'In a number code, PLUM is written as 4573. Using the same code, what is LUMP?',
    options: ['5734', '5743', '4735', '3574', '5347'],
    answerIndex: 0,
    explanation:
      '**Step 1:** Match each letter to its digit in order: P=4, L=5, U=7, M=3.\n\n**Step 2:** Now spell LUMP using those digits: L=5, U=7, M=3, P=4.\n\n**Step 3:** Read them off: **5734**.\n\n**Exam tip:** Write the letter–number pairs as a little table before answering. LUMP uses exactly the same letters as PLUM, just rearranged — so the answer must use exactly the digits 3, 4, 5 and 7 once each. That instantly eliminates any option with a repeated digit.',
  },
  {
    id: 'V9',
    type: VERBAL,
    topic: 'Odd One Out',
    prompt: 'Four of these words belong to the same group. Which one is the odd one out?',
    options: ['apple', 'plum', 'carrot', 'peach', 'cherry'],
    answerIndex: 2,
    explanation:
      '**Step 1:** Sort the words into a category: apple, plum, peach and cherry are all **fruits**.\n\n**Step 2:** A carrot is a **vegetable** (a root vegetable, in fact).\n\n**Step 3:** So the odd one out is **carrot**.\n\n**Exam tip:** Find what FOUR words share first, then the leftover is your answer — don\'t hunt for what makes one word different straight away.',
  },
  {
    id: 'V10',
    type: VERBAL,
    topic: 'Synonyms',
    prompt: 'Choose the word closest in meaning to BEGIN.',
    options: ['finish', 'commence', 'pause', 'avoid', 'borrow'],
    answerIndex: 1,
    explanation:
      '**Step 1:** BEGIN means to start something.\n\n**Step 2:** *Finish* is the opposite; *pause* means stop briefly; *avoid* and *borrow* are unrelated.\n\n**Step 3:** *Commence* is a formal word meaning exactly "to start" — the answer is **commence**.\n\n**Vocabulary builder:** GL papers love formal synonyms: commence/begin, purchase/buy, enquire/ask, cease/stop. Learn these pairs!',
  },
  {
    id: 'V11',
    type: VERBAL,
    topic: 'Antonyms',
    prompt: 'Choose the word most opposite in meaning to ANCIENT.',
    options: ['old', 'historic', 'modern', 'antique', 'elderly'],
    answerIndex: 2,
    explanation:
      '**Step 1:** ANCIENT means very, very old — like ancient Egypt.\n\n**Step 2:** Four of the options (*old*, *historic*, *antique*, *elderly*) are all near-synonyms of ancient — classic distractors.\n\n**Step 3:** The only word meaning new or up-to-date is **modern**.\n\n**Exam tip:** When four options feel similar, the "different" one is almost certainly the answer to an OPPOSITE question.',
  },
  {
    id: 'V12',
    type: VERBAL,
    topic: 'Verbal Analogies',
    prompt: 'Kitten is to Cat as Puppy is to … ?',
    options: ['dog', 'wolf', 'foal', 'lamb', 'cub'],
    answerIndex: 0,
    explanation:
      '**Step 1:** Find the relationship in the first pair: a kitten is the **baby** of a cat.\n\n**Step 2:** Apply the same relationship: a puppy is the baby of a … **dog**.\n\n**Step 3:** Check the traps: a foal is a baby horse, a lamb is a baby sheep, a cub is a baby bear or lion — all babies, but the question needs the *parent* of a puppy.\n\n**Exam tip:** Say the relationship out loud as a sentence ("… is the baby of …") and reuse the exact sentence for the second pair.',
  },
  {
    id: 'V13',
    type: VERBAL,
    topic: 'Letter Codes',
    prompt: 'In a secret code, SUN is written as TVO. Using the same code, how is MOON written?',
    options: ['NPPO', 'NOPO', 'MPPO', 'NPOP', 'OPPN'],
    answerIndex: 0,
    explanation:
      '**Step 1:** Crack the code: S→T, U→V, N→O. Every letter steps forward one place (+1).\n\n**Step 2:** Apply +1 to each letter of MOON: M→N, O→P, O→P, N→O.\n\n**Step 3:** The answer is **NPPO**.\n\n**Careful check:** MOON has a double O, so the code must have a double letter in the middle too — that instantly rules out NOPO and NPOP.',
  },
  {
    id: 'V14',
    type: VERBAL,
    topic: 'Letter Sequences',
    prompt: 'Find the next letter in the sequence:  B,  E,  H,  K,  ( ? )',
    options: ['L', 'M', 'N', 'O', 'P'],
    answerIndex: 2,
    explanation:
      '**Step 1:** Work out the jump between letters: B→E is +3, E→H is +3, H→K is +3.\n\n**Step 2:** The rule is "add 3 each time", so continue: K + 3 → L, M, **N**.\n\n**Step 3:** The answer is **N**.\n\n**Exam tip:** Always test your rule on EVERY given step, not just the first one — some sequences change their jump size (+1, +2, +3…).',
  },
  {
    id: 'V15',
    type: VERBAL,
    topic: 'Compound Words',
    prompt: 'Which ONE word can go in front of each of these to make three new words:  LIGHT,  TIME,  DREAM?',
    options: ['NIGHT', 'DAY', 'MOON', 'STAR', 'SUN'],
    answerIndex: 1,
    explanation:
      '**Step 1:** Test each option against ALL three words — the answer must work with every single one.\n\n**Step 2:** Try NIGHT: nightlight ✔, nighttime ✔, nightdream ✘ (not a real word). So close, but it fails the third test.\n\n**Step 3:** Try DAY: **day**light ✔, **day**time ✔, **day**dream ✔. All three work!\n\n**Exam tip:** Never stop after two matches — the examiners choose distractors that work with two of the three words on purpose.',
  },

  /* =========================== NON-VERBAL REASONING =========================== */
  {
    id: 'N1',
    type: NON_VERBAL,
    topic: 'Series (Counting)',
    prompt: 'Look at the pattern. Which group of dots comes next in the series?',
    visual: { kind: 'pattern', lines: ['●    ●●    ●●●    ●●●●    ?'] },
    options: ['●●', '●●●', '●●●●', '●●●●●', '●●●●●●'],
    answerIndex: 3,
    explanation:
      '**Step 1:** Count the dots in each box: 1, 2, 3, 4 …\n\n**Step 2:** The rule is "one more dot each time".\n\n**Step 3:** After 4 comes **5 dots**: ●●●●●.\n\n**Exam tip:** In NVR series, always check the simplest ideas first — counting, then rotation, then shading. Most questions use just one or two rules.',
  },
  {
    id: 'N2',
    type: NON_VERBAL,
    topic: 'Rotation',
    prompt: 'The arrow turns the same amount in the same direction each step. Which arrow comes next?',
    visual: { kind: 'pattern', lines: ['↑    →    ↓    ←    ?'] },
    options: ['↑', '↓', '←', '→', '↗'],
    answerIndex: 0,
    explanation:
      '**Step 1:** Track the arrow: up → right → down → left. Each step it turns 90° (a quarter turn) **clockwise**.\n\n**Step 2:** From left (←), another quarter turn clockwise points it back **up** (↑).\n\n**Step 3:** The answer is **↑**.\n\n**Exam tip:** Imagine a clock face: up is 12, right is 3, down is 6, left is 9. Quarter turns simply hop between these positions.',
  },
  {
    id: 'N3',
    type: NON_VERBAL,
    topic: 'Odd One Out',
    prompt: 'Four of these shapes follow the same rule. Which shape is the odd one out?',
    options: ['■', '●', '▲', '◆', '□'],
    answerIndex: 4,
    explanation:
      '**Step 1:** Look for what most shapes share. Ignore the outline shape itself — compare the **shading**.\n\n**Step 2:** The square ■, circle ●, triangle ▲ and diamond ◆ are all completely **filled in** (solid).\n\n**Step 3:** The last square □ is **hollow** (just an outline) — it breaks the rule, so it is the odd one out.\n\n**Exam tip:** In odd-one-out questions, check one feature at a time: shading, size, number of sides, rotation. Here the shape type varies for everyone, so shading is the real rule.',
  },
  {
    id: 'N4',
    type: NON_VERBAL,
    topic: 'Matrices',
    prompt: 'This 3 × 3 grid follows a pattern. Which shape belongs in the empty square?',
    visual: { kind: 'pattern', lines: ['○ ● ○', '● ○ ●', '○ ● ?'] },
    options: ['○', '●', '◐', '□', '▲'],
    answerIndex: 0,
    explanation:
      '**Step 1:** Read each row like a sentence. Row 1: hollow, filled, hollow. Row 2: filled, hollow, filled. The circles simply **alternate**.\n\n**Step 2:** Row 3 so far: hollow, filled, … following the alternating rule, next must be **hollow** (○).\n\n**Step 3:** Double-check with the columns: column 3 reads hollow, filled, … hollow. Same answer. ✔\n\n**Exam tip:** A matrix answer should work for BOTH its row and its column — checking both is a free way to catch mistakes.',
  },
  {
    id: 'N5',
    type: NON_VERBAL,
    topic: 'Series (Shading)',
    prompt: 'The circle fills up by the same amount each step. Which circle comes next?',
    visual: { kind: 'pattern', lines: ['◔    ◑    ◕    ?'] },
    options: ['○', '◔', '◑', '●', '◕'],
    answerIndex: 3,
    explanation:
      '**Step 1:** Look at how much of each circle is shaded: one quarter (◔), then one half (◑), then three quarters (◕).\n\n**Step 2:** The rule is "add one quarter of shading each step".\n\n**Step 3:** Three quarters + one quarter = a **fully shaded circle** ●.\n\n**Exam tip:** Shading questions are secretly fraction questions — ¼, ½, ¾, whole. Say the fractions in your head as you scan the series.',
  },
  {
    id: 'N6',
    type: NON_VERBAL,
    topic: 'Rotation',
    prompt: 'The shaded half of the circle turns the same amount each step. Which comes next?',
    visual: { kind: 'pattern', lines: ['◐    ◓    ◑    ◒    ?'] },
    options: ['◐', '◑', '◒', '◓', '●'],
    answerIndex: 0,
    explanation:
      '**Step 1:** Track WHERE the shaded half sits: left (◐), then top (◓), then right (◑), then bottom (◒).\n\n**Step 2:** The shading rotates 90° clockwise each step: left → top → right → bottom.\n\n**Step 3:** After bottom, another quarter turn clockwise brings it back to the **left**: ◐.\n\n**Exam tip:** Rotations repeat every 4 quarter-turns — position 5 in a series is always the same as position 1.',
  },
  {
    id: 'N7',
    type: NON_VERBAL,
    topic: 'Reflection (Mirror Images)',
    prompt:
      'Imagine holding the letter  b  up to a mirror standing on its right-hand side. Which letter shape would you see in the mirror?',
    options: ['d', 'p', 'q', 'b', 'o'],
    answerIndex: 0,
    explanation:
      '**Step 1:** A mirror on the side swaps LEFT and RIGHT, but never up and down.\n\n**Step 2:** The letter **b** has a stick on the left and a bowl on the right. Flipping left–right puts the stick on the right and the bowl on the left.\n\n**Step 3:** That is exactly the letter **d**.\n\n**Common trap:** *p* and *q* are what you get by flipping UPSIDE-DOWN — a mirror at the side never does that.',
  },
  {
    id: 'N8',
    type: NON_VERBAL,
    topic: '3D Reasoning',
    prompt:
      'A cube has a star ★ on its top face, a heart ♥ on its front face, and a moon ☽ on its right face. The cube is tipped over backwards, so the top face rolls to the back. Which symbol now faces upwards?',
    options: ['★ star', '♥ heart', '☽ moon', '☀ sun', 'Cannot tell'],
    answerIndex: 1,
    explanation:
      '**Step 1:** Picture (or mime with a dice or a rubber!) tipping a cube backwards: the whole cube rolls away from you.\n\n**Step 2:** Track each face: the top (★) rolls to the back; the front (♥) swings up to become the new **top**; the bottom becomes the new front.\n\n**Step 3:** The right face (☽) is on the rolling axis, so it doesn\'t move. The face now pointing up is the **heart ♥**.\n\n**Exam tip:** For rolling-cube questions, the two faces on the sides of the roll never move — only the other four faces rotate around, like a wheel.',
  },
  {
    id: 'N9',
    type: NON_VERBAL,
    topic: 'Shape Analogies',
    prompt: '△ is to ▲ as ○ is to … ?',
    visual: { kind: 'pattern', lines: ['△ → ▲        ○ → ?'] },
    options: ['○', '●', '◐', '□', '▲'],
    answerIndex: 1,
    explanation:
      '**Step 1:** Work out what changed in the first pair: the triangle stays a triangle, same size, but goes from hollow (△) to **filled in** (▲).\n\n**Step 2:** Apply exactly the same change to the circle: hollow ○ becomes filled ●.\n\n**Step 3:** The answer is **●**.\n\n**Exam tip:** In shape analogies, list the changes as a checklist — shape? size? shading? rotation? — then tick off the same list on the second pair.',
  },
  {
    id: 'N10',
    type: NON_VERBAL,
    topic: 'Matrices',
    prompt: 'This 3 × 3 grid follows a pattern across each row. What belongs in the empty square?',
    visual: { kind: 'pattern', lines: ['▲   ▲▲   ▲▲▲', '●   ●●   ●●●', '■   ■■   ?'] },
    options: ['■', '■■', '■■■', '■■■■', '●●●'],
    answerIndex: 2,
    explanation:
      '**Step 1:** Read across each row: one shape, then two, then three. The count grows by one across every row.\n\n**Step 2:** Read down each column: the shape changes (triangle → circle → square) but the count stays the same.\n\n**Step 3:** The empty square is in the squares row, third column — so it needs **three squares: ■■■**.\n\n**Exam tip:** The answer must satisfy its row rule (count of 3) AND its column rule (square shape). Option ●●● has the right count but the wrong shape!',
  },
  {
    id: 'N11',
    type: NON_VERBAL,
    topic: 'Rotation (Shapes)',
    prompt: 'This L-shape rotates by the same quarter turn each step. Which picture comes next?',
    visual: { kind: 'lshape-sequence', rotations: [0, 90, 180] },
    options: [
      { kind: 'lshape', rotation: 270 },
      { kind: 'lshape', rotation: 0 },
      { kind: 'lshape', rotation: 90 },
      { kind: 'lshape', rotation: 0, mirrored: true },
      { kind: 'lshape', rotation: 180 },
    ],
    answerIndex: 0,
    explanation:
      '**Step 1:** Compare picture 1 and picture 2: the L-shape has turned 90° (a quarter turn) **clockwise**.\n\n**Step 2:** Check it continues: picture 2 to picture 3 is another quarter turn clockwise. The rule is confirmed.\n\n**Step 3:** Apply one more quarter turn clockwise to picture 3. The foot of the L swings round to its final position — answer **A**.\n\n**Common trap:** One of the wrong options is a MIRROR IMAGE of the correct answer. A rotation can never turn a shape into its mirror image — if it looks "flipped", it\'s wrong.',
  },
  {
    id: 'N12',
    type: NON_VERBAL,
    topic: 'Odd One Out',
    prompt: 'Four of these shapes follow the same rule. Which is the odd one out?',
    options: ['□ square', '▭ rectangle', '◇ diamond', '△ triangle', '▱ parallelogram'],
    answerIndex: 3,
    explanation:
      '**Step 1:** Count the sides of each shape: square = 4, rectangle = 4, diamond = 4, parallelogram = 4.\n\n**Step 2:** The triangle has only **3 sides** — it breaks the rule that every shape is a quadrilateral (4-sided).\n\n**Step 3:** The odd one out is the **triangle △**.\n\n**Exam tip:** "Count the sides" is one of the most common NVR odd-one-out rules — always try it early, before hunting for cleverer patterns.',
  },
];
