import '../core/constants.dart';
import '../models/task.dart';

class TaskRepository {
  TaskRepository._();

  static final List<Task> _allTasks = _buildAll();

  static List<Task> _buildAll() {
    return [
      ..._buildLettersTasks(),
      ..._buildMathTasks(),
      ..._buildWorldTasks(),
    ];
  }

  static List<Task> all() => _allTasks;

  static List<Task> byBlock(TaskBlock block) {
    return _allTasks.where((t) => t.block == block).toList();
  }

  static List<Task> session(TaskBlock block, {int count = 10}) {
    final tasks = byBlock(block)..shuffle();
    return tasks.take(count).toList();
  }

  // ── БЛОК 1: БУКВЫ И ЧТЕНИЕ ────────────────────────────────────────────

  static List<Task> _buildLettersTasks() {
    final list = <Task>[];
    var id = 0;

    // 1.1 назови букву (name the letter)
    _add(list, id++, TaskBlock.letters, TaskType.nameLetter, 1,
        'Посмотри на букву и назови её',
        _accept('а', 'буква а', 'аа'), 'Это первая буква алфавита');
    _add(list, id++, TaskBlock.letters, TaskType.nameLetter, 1,
        'Какая это буква?',
        _accept('м', 'буква м', 'эм'), 'Мама начинается с этой буквы');
    _add(list, id++, TaskBlock.letters, TaskType.nameLetter, 1,
        'Назови эту букву',
        _accept('о', 'буква о', 'ооо'), 'Она похожа на колесо');
    _add(list, id++, TaskBlock.letters, TaskType.nameLetter, 1,
        'Что за буква перед тобой?',
        _accept('п', 'буква п', 'пэ'), 'Папа начинается с этой буквы');

    // 1.2 найди звук (find the sound)
    _add(list, id++, TaskBlock.letters, TaskType.findSound, 1,
        'Какой первый звук в слове «мама»?',
        _accept('м', 'звук м', 'ммм'), 'Послушай: м-м-мама');
    _add(list, id++, TaskBlock.letters, TaskType.findSound, 1,
        'С какого звука начинается слово «кот»?',
        _accept('к', 'звук к', 'ккк'), 'Послушай начало: к-к-кот');
    _add(list, id++, TaskBlock.letters, TaskType.findSound, 2,
        'Какой звук в середине слова «лиса»?',
        _accept('с', 'звук с', 'ссс'), 'Протяни слово: ли-с-са');
    _add(list, id++, TaskBlock.letters, TaskType.findSound, 2,
        'Какой последний звук в слове «дом»?',
        _accept('м', 'звук м', 'мм'), 'До-ммм — что слышишь в конце?');

    // 1.3 придумай слово (make up a word)
    _add(list, id++, TaskBlock.letters, TaskType.inventWord, 1,
        'Придумай слово, которое начинается на букву А',
        _accept('арбуз', 'аист', 'автобус', 'ананас'), 'Например: ааарбуз!');
    _add(list, id++, TaskBlock.letters, TaskType.inventWord, 2,
        'Назови слово на букву К',
        _accept('кот', 'кит', 'книга', 'кукла', 'каша'), 'К-к-кот, к-к-кит…');
    _add(list, id++, TaskBlock.letters, TaskType.inventWord, 2,
        'Придумай слово, которое начинается на М',
        _accept('мама', 'мяч', 'море', 'молоко', 'мир'), 'Ма-ма, мя-мяч…');
    _add(list, id++, TaskBlock.letters, TaskType.inventWord, 1,
        'Скажи любое слово на букву С',
        _accept('сон', 'сок', 'сова', 'солнце', 'стул'), 'С-с-сон, с-с-солнце…');

    // 1.4 хлопни когда услышишь (clap when you hear)
    _add(list, id++, TaskBlock.letters, TaskType.clapWhenHear, 2,
        'Хлопни в ладоши, когда услышишь звук С! Слушай: М, С, О, У',
        _accept('хлоп', 'хлопаю', 'хлопнул'), 'Слушай внимательно: М… С!');
    _add(list, id++, TaskBlock.letters, TaskType.clapWhenHear, 2,
        'Хлопни, если услышишь К: А, К, Т, И',
        _accept('хлоп', 'хлопаю', 'хлопнул'), 'Буква К прозвучала!');
    _add(list, id++, TaskBlock.letters, TaskType.clapWhenHear, 3,
        'Хлопни на звук Р: Л, Р, Н, П',
        _accept('хлоп', 'хлопаю', 'хлопнул'), 'Р-р-р рычит!');
    _add(list, id++, TaskBlock.letters, TaskType.clapWhenHear, 2,
        'Хлопни на звук Ш: С, Ш, Ж, З',
        _accept('хлоп', 'хлопаю', 'хлопнул'), 'Ш-ш-ш шипит как змея!');

    // 1.5 твёрдый/мягкий (hard/soft consonant)
    _add(list, id++, TaskBlock.letters, TaskType.hardSoft, 2,
        'Какой звук М в слове «мама» — твёрдый или мягкий?',
        _accept('твёрдый', 'твердый'), 'М-м-мама — звучит твёрдо');
    _add(list, id++, TaskBlock.letters, TaskType.hardSoft, 2,
        'А в слове «мир» звук М твёрдый или мягкий?',
        _accept('мягкий', 'мягкий'), 'Мь-мь-мир — звучит мягко');
    _add(list, id++, TaskBlock.letters, TaskType.hardSoft, 3,
        'Скажи: звук Л в слове «лук» — твёрдый или мягкий?',
        _accept('твёрдый', 'твердый'), 'Л-л-лук — язык упирается, звук твёрдый');
    _add(list, id++, TaskBlock.letters, TaskType.hardSoft, 3,
        'Звук Л в слове «лист» — твёрдый или мягкий?',
        _accept('мягкий', 'мягкий'), 'Ль-ль-лист — язык поднимается к нёбу');

    // 1.6 слоги (syllables)
    _add(list, id++, TaskBlock.letters, TaskType.syllables, 1,
        'Сколько слогов в слове «ма-ма»? Два или три?',
        _accept('два', '2', 'два слога'), 'Прохлопай: ма (хлоп) — ма (хлоп)');
    _add(list, id++, TaskBlock.letters, TaskType.syllables, 2,
        'Раздели слово «кошка» на слоги. Сколько получилось?',
        _accept('два', '2', 'два слога', 'кош-ка'), 'Кош-ка — два хлопка');
    _add(list, id++, TaskBlock.letters, TaskType.syllables, 2,
        'Сколько слогов в слове «собака»?',
        _accept('три', '3', 'три слога'), 'Со-ба-ка — три хлопка');
    _add(list, id++, TaskBlock.letters, TaskType.syllables, 3,
        'Сколько слогов в слове «черепаха»?',
        _accept('четыре', '4', 'четыре слога'), 'Че-ре-па-ха — четыре!');

    // 1.7 рифма (rhyme)
    _add(list, id++, TaskBlock.letters, TaskType.rhyme, 2,
        'Подбери рифму к слову «кошка». Кошка — …',
        _accept('мошка', 'ложка', 'окрошка', 'дорожка', 'крошка', 'лукошко', 'картошка', 'матрёшка'),
        'Кошка — мошка, кошка — ложка!');
    _add(list, id++, TaskBlock.letters, TaskType.rhyme, 2,
        'Рифма к слову «мишка»: мишка — …',
        _accept('шишка', 'книжка', 'мышка', 'малышка', 'вспышка'),
        'Мишка-шишка, мишка-книжка!');
    _add(list, id++, TaskBlock.letters, TaskType.rhyme, 3,
        'Придумай рифму к слову «дом». Дом — …',
        _accept('гном', 'сон', 'ком', 'том', 'гром', 'альбом'),
        'Дом-гном, дом-сон!');
    _add(list, id++, TaskBlock.letters, TaskType.rhyme, 3,
        'Рифма к слову «речка»: речка — …',
        _accept('печка', 'свечка', 'овечка', 'гречка', 'уздечка'),
        'Речка-печка, речка-свечка!');

    // 1.8 буква потерялась (lost letter)
    _add(list, id++, TaskBlock.letters, TaskType.lostLetter, 2,
        'В слове «_от» потерялась первая буква. Какая? Подсказка: пушистый друг',
        _accept('к', 'буква к'), 'Мяу! Кто это? К-от!');
    _add(list, id++, TaskBlock.letters, TaskType.lostLetter, 2,
        'В слове «д_м» пропущена буква. Какая?',
        _accept('о', 'буква о'), 'Там мы живём. Дом!');
    _add(list, id++, TaskBlock.letters, TaskType.lostLetter, 3,
        '«_ес» — потерялась первая буква. Что за слово?',
        _accept('л', 'буква л'), 'Там много деревьев. Лес!');
    _add(list, id++, TaskBlock.letters, TaskType.lostLetter, 3,
        '«со_» — в конце не хватает буквы. Какой?',
        _accept('к', 'буква к'), 'Мы пьём его по утрам. Сок!');

    // 1.9 гласная/согласная (vowel/consonant)
    _add(list, id++, TaskBlock.letters, TaskType.vowelConsonant, 1,
        'Буква А — гласная или согласная?',
        _accept('гласная', 'гласная буква'), 'Её можно петь: а-а-а-а-а!');
    _add(list, id++, TaskBlock.letters, TaskType.vowelConsonant, 2,
        'Буква М — гласная или согласная?',
        _accept('согласная', 'согласная буква'), 'Её нельзя пропеть — губы смыкаются');
    _add(list, id++, TaskBlock.letters, TaskType.vowelConsonant, 2,
        'Звук У — гласный или согласный?',
        _accept('гласный', 'гласная', 'гласный звук'), 'Тянется: у-у-у-у!');
    _add(list, id++, TaskBlock.letters, TaskType.vowelConsonant, 3,
        'Звук С — гласный или согласный?',
        _accept('согласный', 'согласный звук'), 'Свистит, но не поётся');

    // 1.10 составь слово из звуков (build word from sounds)
    _add(list, id++, TaskBlock.letters, TaskType.buildWord, 2,
        'Какое слово получится из звуков: Д, О, М?',
        _accept('дом'), 'Сложи звуки вместе: д-о-м');
    _add(list, id++, TaskBlock.letters, TaskType.buildWord, 2,
        'Соедини звуки: К, О, Т. Что за слово?',
        _accept('кот'), 'К-о-т — кто мяукает?');
    _add(list, id++, TaskBlock.letters, TaskType.buildWord, 3,
        'Из звуков С, О, К получится слово?',
        _accept('сок'), 'С-о-к — вкусный и полезный!');
    _add(list, id++, TaskBlock.letters, TaskType.buildWord, 3,
        'Звуки: Ш, А, Р. Какое слово?',
        _accept('шар'), 'Ш-а-р — круглый, воздушный!');

    return list;
  }

  // ── БЛОК 2: МАТЕМАТИКА И ЛОГИКА ────────────────────────────────────────

  static List<Task> _buildMathTasks() {
    final list = <Task>[];
    var id = 100;

    // 2.1 посчитай (count)
    _add(list, id++, TaskBlock.math, TaskType.count, 1,
        'Посчитай: один, два, три… что дальше?',
        _accept('четыре', '4'), 'После трёх идёт… четыре!');
    _add(list, id++, TaskBlock.math, TaskType.count, 2,
        'Сколько будет пальцев на одной руке?',
        _accept('пять', '5'), 'Загни пальчики: раз, два, три, четыре, пять!');
    _add(list, id++, TaskBlock.math, TaskType.count, 2,
        'Сосчитай от одного до десяти. Какое число после девяти?',
        _accept('десять', '10'), 'Девять… и десять!');
    _add(list, id++, TaskBlock.math, TaskType.count, 1,
        'Сколько ушей у кошки?',
        _accept('два', '2'), 'Одно ушко, второе ушко!');

    // 2.2 сложение (addition)
    _add(list, id++, TaskBlock.math, TaskType.addition, 1,
        'У тебя было два яблока, мама дала ещё одно. Сколько стало?',
        _accept('три', '3'), 'Два плюс один — это три!');
    _add(list, id++, TaskBlock.math, TaskType.addition, 2,
        'Сколько будет: один плюс четыре?',
        _accept('пять', '5'), 'Раз, два, три, четыре, пять!');
    _add(list, id++, TaskBlock.math, TaskType.addition, 2,
        'Три конфеты и ещё две конфеты — сколько вместе?',
        _accept('пять', '5'), 'Три и два будет пять!');
    _add(list, id++, TaskBlock.math, TaskType.addition, 3,
        'Сколько будет: два плюс три?',
        _accept('пять', '5'), 'На пальцах: два и три — пять!');

    // 2.3 вычитание (subtraction)
    _add(list, id++, TaskBlock.math, TaskType.subtraction, 2,
        'У тебя было пять конфет, одну ты съел. Сколько осталось?',
        _accept('четыре', '4'), 'Пять минус один — четыре!');
    _add(list, id++, TaskBlock.math, TaskType.subtraction, 2,
        'На ветке сидели три птички, одна улетела. Сколько осталось?',
        _accept('две', '2', 'два'), 'Три без одной — две!');
    _add(list, id++, TaskBlock.math, TaskType.subtraction, 3,
        'Сколько будет: четыре минус два?',
        _accept('два', '2'), 'Четыре без двух — два!');
    _add(list, id++, TaskBlock.math, TaskType.subtraction, 3,
        'В коробке было шесть карандашей, два сломались. Сколько целых?',
        _accept('четыре', '4'), 'Шесть минус два — четыре!');

    // 2.4 больше/меньше (greater/less)
    _add(list, id++, TaskBlock.math, TaskType.greaterLess, 1,
        'Что больше: пять или три?',
        _accept('пять', '5', 'больше пять'), 'Пять больше, чем три!');
    _add(list, id++, TaskBlock.math, TaskType.greaterLess, 2,
        'Какое число меньше: два или семь?',
        _accept('два', '2', 'меньше два'), 'Два меньше семи!');
    _add(list, id++, TaskBlock.math, TaskType.greaterLess, 2,
        'Кто выше: жираф или мышка?',
        _accept('жираф'), 'Жираф намного выше мышки!');
    _add(list, id++, TaskBlock.math, TaskType.greaterLess, 1,
        'Что тяжелее: пёрышко или камень?',
        _accept('камень', 'тяжелее камень'), 'Камень тяжелее пёрышка!');

    // 2.5 соседи числа (number neighbors)
    _add(list, id++, TaskBlock.math, TaskType.numberNeighbors, 2,
        'Назови соседей числа три. Какое число перед тройкой и после неё?',
        _accept('два и четыре', '2 и 4', 'два четыре'), 'Перед тройкой — два, после — четыре!');
    _add(list, id++, TaskBlock.math, TaskType.numberNeighbors, 2,
        'Кто соседи числа пять?',
        _accept('четыре и шесть', '4 и 6', 'четыре шесть'), 'Четыре и шесть стоят рядом с пятёркой!');
    _add(list, id++, TaskBlock.math, TaskType.numberNeighbors, 3,
        'Назови соседей семи',
        _accept('шесть и восемь', '6 и 8', 'шесть восемь'), 'Перед семёркой — шесть, после — восемь!');
    _add(list, id++, TaskBlock.math, TaskType.numberNeighbors, 3,
        'Какие числа живут рядом с единицей? Спереди и сзади?',
        _accept('ноль и два', '0 и 2', 'ноль два'), 'Перед единицей — ноль, после — два!');

    // 2.6 продолжи ряд (continue sequence)
    _add(list, id++, TaskBlock.math, TaskType.continueSequence, 2,
        'Продолжи: один, два, три, …',
        _accept('четыре', '4'), 'После трёх идёт четыре!');
    _add(list, id++, TaskBlock.math, TaskType.continueSequence, 2,
        'Что дальше: два, четыре, шесть, …?',
        _accept('восемь', '8', 'восемь'), 'Прибавляем по два: шесть плюс два — восемь!');
    _add(list, id++, TaskBlock.math, TaskType.continueSequence, 3,
        'Продолжи ряд: пять, четыре, три, …',
        _accept('два', '2'), 'Убывает на один: три, два, один!');
    _add(list, id++, TaskBlock.math, TaskType.continueSequence, 3,
        'Что дальше: десять, девять, восемь, …?',
        _accept('семь', '7'), 'Обратный отсчёт: восемь, семь!');

    // 2.7 фигуры (shapes)
    _add(list, id++, TaskBlock.math, TaskType.shapes, 1,
        'На что похож круг? Назови предмет',
        _accept('солнце', 'колесо', 'мяч', 'тарелка', 'часы', 'апельсин'),
        'Мячик, солнышко, колесо — всё круглое!');
    _add(list, id++, TaskBlock.math, TaskType.shapes, 1,
        'Сколько углов у квадрата?',
        _accept('четыре', '4', 'четыре угла'), 'Раз, два, три, четыре!');
    _add(list, id++, TaskBlock.math, TaskType.shapes, 2,
        'Сколько углов у треугольника?',
        _accept('три', '3', 'три угла'), 'Один, два, три угла!');
    _add(list, id++, TaskBlock.math, TaskType.shapes, 2,
        'Какая фигура похожа на яйцо?',
        _accept('овал', 'овальная', 'овал'), 'Овал — вытянутый круг!');

    // 2.8 логическая задача (logic puzzle)
    _add(list, id++, TaskBlock.math, TaskType.logicPuzzle, 3,
        'У мамы-кошки два котёнка. Один рыжий, другой нет. Какой второй?',
        _accept('чёрный', 'серый', 'белый', 'не рыжий', 'другого цвета'),
        'Если не рыжий — значит другого цвета!');
    _add(list, id++, TaskBlock.math, TaskType.logicPuzzle, 3,
        'Что тяжелее: килограмм пуха или килограмм камней?',
        _accept('одинаково', 'равно', 'одинаково весят', 'поровну'),
        'Килограмм — он и есть килограмм! Всё равно!');
    _add(list, id++, TaskBlock.math, TaskType.logicPuzzle, 3,
        'У папы есть дочка, но она не сестра тебе. Кто она?',
        _accept('я', 'ты', 'это я', 'сам'),
        'Если у папы дочка — это ты и есть!');
    _add(list, id++, TaskBlock.math, TaskType.logicPuzzle, 3,
        'Ты да я, да мы с тобой. Сколько нас?',
        _accept('двое', 'два', '2'), 'Ты плюс я — двое!');

    // 2.9 сравни предметы (compare objects)
    _add(list, id++, TaskBlock.math, TaskType.compareObjects, 1,
        'Дерево высокое, а кустик какой?',
        _accept('низкий', 'маленький', 'невысокий'), 'Кустик ниже дерева!');
    _add(list, id++, TaskBlock.math, TaskType.compareObjects, 1,
        'Река широкая, а ручеёк какой?',
        _accept('узкий', 'маленький', 'тонкий'), 'Ручеёк узкий!');
    _add(list, id++, TaskBlock.math, TaskType.compareObjects, 2,
        'Слон большой, а мышка…',
        _accept('маленькая', 'мелкая'), 'Мышка маленькая!');
    _add(list, id++, TaskBlock.math, TaskType.compareObjects, 2,
        'Лёд холодный, а огонь…',
        _accept('горячий', 'тёплый', 'жаркий'), 'Огонь горячий!');

    // 2.10 время (time)
    _add(list, id++, TaskBlock.math, TaskType.time, 3,
        'Когда ты завтракаешь: утром или вечером?',
        _accept('утром', 'утро'), 'Утром мы завтракаем!');
    _add(list, id++, TaskBlock.math, TaskType.time, 2,
        'Когда на небе звёзды: днём или ночью?',
        _accept('ночью', 'ночь'), 'Ночью видны звёзды!');
    _add(list, id++, TaskBlock.math, TaskType.time, 3,
        'Что длится дольше: час или минута?',
        _accept('час', 'час дольше'), 'Час — это целых 60 минут!');
    _add(list, id++, TaskBlock.math, TaskType.time, 3,
        'Сколько дней в неделе?',
        _accept('семь', '7', 'семь дней'), 'ПН ВТ СР ЧТ ПТ СБ ВС — семь!');

    return list;
  }

  // ── БЛОК 3: ОКРУЖАЮЩИЙ МИР И РЕЧЬ ────────────────────────────────────────

  static List<Task> _buildWorldTasks() {
    final list = <Task>[];
    var id = 200;

    // 3.1 кто как говорит (who says what)
    _add(list, id++, TaskBlock.world, TaskType.whoSays, 1,
        'Кто говорит «му-у»?',
        _accept('корова', 'корова'), 'Корова мычит: му-у-у!');
    _add(list, id++, TaskBlock.world, TaskType.whoSays, 1,
        'Кто говорит «мяу»?',
        _accept('кошка', 'кот', 'котик'), 'Кошечка мяукает: мяу!');
    _add(list, id++, TaskBlock.world, TaskType.whoSays, 1,
        'Кто говорит «гав-гав»?',
        _accept('собака', 'собачка', 'пёс'), 'Собака лает: гав-гав!');
    _add(list, id++, TaskBlock.world, TaskType.whoSays, 2,
        'Кто говорит «хрю-хрю»?',
        _accept('свинья', 'свинка', 'поросёнок'), 'Свинка хрюкает!');

    // 3.2 назови детёныша (name the baby animal)
    _add(list, id++, TaskBlock.world, TaskType.nameBaby, 1,
        'У кошки детёныш — … Кто?',
        _accept('котёнок', 'котенок'), 'Маленький котёнок! Мяу!');
    _add(list, id++, TaskBlock.world, TaskType.nameBaby, 1,
        'У собаки малыш — кто?',
        _accept('щенок', 'щенок', 'собачка маленькая'), 'Щенок! Гав!');
    _add(list, id++, TaskBlock.world, TaskType.nameBaby, 2,
        'У курицы детёныш — …',
        _accept('цыплёнок', 'цыпленок'), 'Цыплёнок! Жёлтенький, пушистый!');
    _add(list, id++, TaskBlock.world, TaskType.nameBaby, 2,
        'У коровы малыш — …',
        _accept('телёнок', 'теленок'), 'Телёнок! Му-у!');

    // 3.3 что лишнее (what's extra)
    _add(list, id++, TaskBlock.world, TaskType.whatIsExtra, 2,
        'Что лишнее: яблоко, груша, огурец, апельсин?',
        _accept('огурец'), 'Огурец — овощ, а остальные фрукты!');
    _add(list, id++, TaskBlock.world, TaskType.whatIsExtra, 2,
        'Что лишнее: кошка, собака, стол, корова?',
        _accept('стол'), 'Стол — мебель, а остальные животные!');
    _add(list, id++, TaskBlock.world, TaskType.whatIsExtra, 3,
        'Что лишнее: шапка, шарф, ботинки, варежки?',
        _accept('ботинки'), 'Ботинки — обувь, остальное для головы и рук!');
    _add(list, id++, TaskBlock.world, TaskType.whatIsExtra, 3,
        'Что лишнее: самолёт, машина, велосипед, тарелка?',
        _accept('тарелка'), 'Тарелка — посуда, остальное транспорт!');

    // 3.4 опиши предмет (describe object)
    _add(list, id++, TaskBlock.world, TaskType.describeObject, 2,
        'Опиши яблоко. Какое оно?',
        _accept('круглое', 'красное', 'вкусное', 'сладкое', 'сочное', 'зелёное'),
        'Яблоко круглое, сладкое, сочное!');
    _add(list, id++, TaskBlock.world, TaskType.describeObject, 2,
        'Опиши мячик. Какой он?',
        _accept('круглый', 'прыгучий', 'резиновый', 'красный', 'весёлый'),
        'Мячик круглый, прыгучий!');
    _add(list, id++, TaskBlock.world, TaskType.describeObject, 2,
        'Расскажи про солнышко. Какое оно?',
        _accept('жёлтое', 'тёплое', 'круглое', 'яркое', 'горячее', 'доброе'),
        'Солнышко жёлтое, тёплое, яркое!');
    _add(list, id++, TaskBlock.world, TaskType.describeObject, 3,
        'Опиши снег. Какой он?',
        _accept('белый', 'холодный', 'пушистый', 'мягкий', 'мокрый'),
        'Снег белый, холодный, пушистый!');

    // 3.5 времена года (seasons)
    _add(list, id++, TaskBlock.world, TaskType.seasons, 2,
        'Когда на деревьях распускаются листья: весной или осенью?',
        _accept('весной', 'весна'), 'Весной всё просыпается!');
    _add(list, id++, TaskBlock.world, TaskType.seasons, 2,
        'Когда можно купаться в речке: летом или зимой?',
        _accept('летом', 'лето'), 'Летом тепло — можно купаться!');
    _add(list, id++, TaskBlock.world, TaskType.seasons, 2,
        'Когда падают жёлтые листья: осенью или весной?',
        _accept('осенью', 'осень'), 'Осенью листья опадают!');
    _add(list, id++, TaskBlock.world, TaskType.seasons, 3,
        'Назови все четыре времени года',
        _accept('зима весна лето осень', 'весна лето осень зима', 'лето осень зима весна'),
        'Зима, весна, лето, осень!');

    // 3.6 что из чего (what from what)
    _add(list, id++, TaskBlock.world, TaskType.madeOf, 2,
        'Из чего делают бумагу?',
        _accept('из дерева', 'дерево', 'из деревьев', 'древесина'),
        'Бумагу делают из деревьев!');
    _add(list, id++, TaskBlock.world, TaskType.madeOf, 2,
        'Из чего делают стекло?',
        _accept('из песка', 'песок'), 'Стекло делают из песка!');
    _add(list, id++, TaskBlock.world, TaskType.madeOf, 3,
        'Из чего пекут хлеб?',
        _accept('из муки', 'мука', 'из теста', 'тесто'), 'Хлеб пекут из муки!');
    _add(list, id++, TaskBlock.world, TaskType.madeOf, 3,
        'Что делают из молока?',
        _accept('сыр', 'творог', 'сметана', 'масло', 'кефир', 'йогурт'),
        'Из молока делают сыр, творог, сметану!');

    // 3.7 профессии (professions)
    _add(list, id++, TaskBlock.world, TaskType.professions, 2,
        'Кто лечит людей?',
        _accept('врач', 'доктор'), 'Врач лечит людей!');
    _add(list, id++, TaskBlock.world, TaskType.professions, 2,
        'Кто учит детей в школе?',
        _accept('учитель', 'учительница'), 'Учитель учит детей!');
    _add(list, id++, TaskBlock.world, TaskType.professions, 3,
        'Кто тушит пожары?',
        _accept('пожарный', 'пожарные'), 'Пожарный тушит огонь!');
    _add(list, id++, TaskBlock.world, TaskType.professions, 3,
        'Кто готовит еду в ресторане?',
        _accept('повар'), 'Повар готовит вкусную еду!');

    // 3.8 что перепутал художник (what did artist mess up)
    _add(list, id++, TaskBlock.world, TaskType.artistMistake, 3,
        'Художник нарисовал рыбу, летящую в небе. Что неправильно?',
        _accept('рыба не летает', 'рыба плавает', 'рыба в воде'),
        'Рыбы плавают в воде, а не летают!');
    _add(list, id++, TaskBlock.world, TaskType.artistMistake, 3,
        'Художник нарисовал зелёное солнце. Что перепутал?',
        _accept('солнце жёлтое', 'солнце не зелёное', 'цвет'),
        'Солнце жёлтое, а не зелёное!');
    _add(list, id++, TaskBlock.world, TaskType.artistMistake, 3,
        'На картинке слон с коротким хоботом. В чём ошибка?',
        _accept('длинный хобот', 'у слона длинный хобот', 'хобот длинный'),
        'У слона длинный хобот!');
    _add(list, id++, TaskBlock.world, TaskType.artistMistake, 3,
        'Художник нарисовал зиму с цветущими деревьями. Что не так?',
        _accept('зимой не цветут', 'зимой холодно', 'деревья зимой без листьев'),
        'Зимой деревья не цветут — слишком холодно!');

    // 3.9 что сначала/потом (what first/then)
    _add(list, id++, TaskBlock.world, TaskType.whatFirst, 3,
        'Что сначала, а что потом: яйцо или курица?',
        _accept('яйцо', 'сначала яйцо'), 'Сначала яйцо, потом цыплёнок, потом курица!');
    _add(list, id++, TaskBlock.world, TaskType.whatFirst, 2,
        'Что сначала: идём в магазин или достаём кошелёк?',
        _accept('достаём кошелёк', 'кошелёк'), 'Сначала кошелёк, потом в магазин!');
    _add(list, id++, TaskBlock.world, TaskType.whatFirst, 2,
        'Что сначала: чистим зубы или завтракаем?',
        _accept('чистим зубы', 'зубы'), 'Сначала чистим зубы, потом завтракаем!');
    _add(list, id++, TaskBlock.world, TaskType.whatFirst, 3,
        'Что сначала: сажаем семечко или вырастает цветок?',
        _accept('сажаем семечко', 'семечко', 'сажать'), 'Сначала семечко, потом росток, потом цветок!');

    // 3.10 скажи наоборот (say the opposite)
    _add(list, id++, TaskBlock.world, TaskType.sayOpposite, 2,
        'Скажи наоборот: большой — …',
        _accept('маленький'), 'Противоположность большого — маленький!');
    _add(list, id++, TaskBlock.world, TaskType.sayOpposite, 2,
        'Скажи наоборот: день — …',
        _accept('ночь'), 'Дню противоположна ночь!');
    _add(list, id++, TaskBlock.world, TaskType.sayOpposite, 3,
        'Скажи наоборот: горячий — …',
        _accept('холодный'), 'Горячему наоборот — холодный!');
    _add(list, id++, TaskBlock.world, TaskType.sayOpposite, 3,
        'Скажи наоборот: добрый — …',
        _accept('злой'), 'Доброму наоборот — злой!');

    return list;
  }

  // ── Помощники ──────────────────────────────────────────────────────────

  static List<String> _accept(String a,
      [String b = '', String c = '', String d = '', String e = '',
      String f = '', String g = '', String h = '']) {
    return [a, b, c, d, e, f, g, h].where((s) => s.isNotEmpty).toList();
  }

  static String emojiFor(Task task) {
    switch (task.block) {
      case TaskBlock.letters:
        switch (task.type) {
          case TaskType.nameLetter: return '🔤';
          case TaskType.findSound: return '👂';
          case TaskType.inventWord: return '💡';
          case TaskType.clapWhenHear: return '👏';
          case TaskType.hardSoft: return '🪨';
          case TaskType.syllables: return '✂️';
          case TaskType.rhyme: return '🎵';
          case TaskType.lostLetter: return '🔍';
          case TaskType.vowelConsonant: return '🎤';
          case TaskType.buildWord: return '🧩';
          default: return '📖';
        }
      case TaskBlock.math:
        switch (task.type) {
          case TaskType.count: return '🔢';
          case TaskType.addition: return '➕';
          case TaskType.subtraction: return '➖';
          case TaskType.greaterLess: return '⚖️';
          case TaskType.numberNeighbors: return '🏠';
          case TaskType.continueSequence: return '➡️';
          case TaskType.shapes: return '🔺';
          case TaskType.logicPuzzle: return '🧠';
          case TaskType.compareObjects: return '📏';
          case TaskType.time: return '⏰';
          default: return '🧮';
        }
      case TaskBlock.world:
        switch (task.type) {
          case TaskType.whoSays: return '🐄';
          case TaskType.nameBaby: return '🐣';
          case TaskType.whatIsExtra: return '❓';
          case TaskType.describeObject: return '🎨';
          case TaskType.seasons: return '🌸';
          case TaskType.madeOf: return '🏭';
          case TaskType.professions: return '👨‍⚕️';
          case TaskType.artistMistake: return '🖼️';
          case TaskType.whatFirst: return '🔄';
          case TaskType.sayOpposite: return '↔️';
          default: return '🌍';
        }
    }
  }

  static void _add(List<Task> list, int id, TaskBlock block, TaskType type,
      int difficulty, String prompt, List<String> accept, String hint) {
    list.add(Task(
      id: '${block.name}_$id',
      block: block,
      type: type,
      difficulty: difficulty,
      prompt: prompt,
      correctAnswerRaw: accept.first,
      acceptedAnswers: accept,
      hint: hint,
    ));
  }
}
