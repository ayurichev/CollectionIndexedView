# CollectionIndexedView

Класс-наследник UICollectionView. Предназначен для замены UITableView, то есть ячейки должны быть шириной во всю ширину collection view. Делает следующие вещи:

- позволяет строить индекс, как у UITableView, но более кастомизируемый (для индекса можно задавать ширину, шрифт, отступы и т.д.);
- по индексу можно как тапать, так и листать его свайпом вверх-вниз (как у таблицы)
- заголовки секций при прокрутке складываются вместе, и можно перейти к нужной секции просто тапнув на её заголовок.

Построение индексов пока ещё не оптимизировалось для экранов iPhone 6/6 Plus, и в целом его нужно переработать. Но пока так.

Идея создания такого функционала возникла в одном из проектов, где требовалось как раз обеспечить складывающиеся и нажимаемые заголовки секций. Несколько дней возни с UITableView показали, что ее средствами обеспечить такой функционал невозможно. Естественно, я стал смотреть в сторону UICollectionView с его мощнейшими возможностями по конструированию собственных layout'ов.
Но поскольку требовалось, чтобы у всей этой конструкции был ещё и индекс, как у таблицы, пришлось писать собственный велосипед.

----------

This is a subclass of UICollectionView. It presents UITableView-like layout with alphabetical index view; also headers in this layout don't hide while collection view performs scrolling. Instead, all headers grouped on top of view in "collapsed" state. By tap on header view, you can "expand" a section that header view presents.

Index view supports scrolling by tap and pan gestures (like UITableView index does), custom fonts and insets (which UITableView doesn't support).

Index is always built for last section of collection view. I wrote this class for special client needs: to provide layout for long lists of names (that can be city names, country names, hotel names). All names will be in last section; first sections contains a "special" lists, i.g. biggest cities and countries, top rated hotels, etc.
