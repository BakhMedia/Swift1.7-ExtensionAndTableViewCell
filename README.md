# Extension и UITableViewCell
### Урок 7.


Сейчас [наше приложение](https://github.com/BakhMedia/Swift1.6-URLSessionAndJSON) выглядит так себе. Сегодня мы займемся украшением нашего **FeedViewController**. Попутно разберем что значат слова lazy, objc. Узнаем чем же примечателен новый год 1970го, почему iOS 8 и меньше не любил этот год и как он связан с 2038ым. А так же напишем расширение, которое позволит нам легко и быстро загружать изображения с **http** прямо в наш **UIImageView**.

Поехали.





В нашем списке **FeedList** сами сами ячейки таблицы слишком маленькие по высоте, чтобы впихнуть туда еще и картинку и скажем дату. Зайдем в файл Main.storyboard выберем наш FeedViewController, в нем выберем feedList и в Size Inspector найдем параметр Row Height, снимем галочку automatic и введем 256.

![Image1](https://raw.githubusercontent.com/BakhMedia/Swift1.7-ExtensionAndTableViewCell/master/images/1.gif "Image1")

Затем откроем FeedItem.xib. Там в размерах указываем 256, можно растянуть и мышкой. Теперь наша ячейка имеет достаточный размер для размещения в ней и изображения и даты.

![Image2](https://raw.githubusercontent.com/BakhMedia/Swift1.7-ExtensionAndTableViewCell/master/images/2.gif "Image2")

2. Далее изменим внешний вид нашей ячейки. Добавим пару ImageView. Первый будет подгружать картинку по ссылке, а второй будет статичным  для улучшения внешнего вида. Так же добавим Label. В нем будет текст: **TEYE GROUP • [ДАТА]**. 

Существующий label спускаем вниз, зададим определенную высоту и сделаем количество строк 2. Добавляем ImageView и растягиваем его между label и верхней границей. Создадим еще один ImageView в него вставляем картинку и делаем её круглой. Размещаем его под первым изображением. Сам же заголовок закрепим справа от него. Добавим еще один Label под заголовок и сделаем его шрифт чуть потусклее, а размер поменьше.

![Image3](https://raw.githubusercontent.com/BakhMedia/Swift1.7-ExtensionAndTableViewCell/master/images/3.gif "Image3")

В итоге у нас получился такой внешний вид. Попробуйте повторить или придумайте свой. Если не получается сделать, пишите в комментариях.


Для новых элементов нам надо создать переменные в файле **FeedItem.swift** или можно сказать создадим связи для этих элементов. Как мы уже умеем в Connections Inspector перетащим **New Referencing Outlet** в файл.3. А так же нам понадобится добавить переменных в наш объект Feed. Теперь его текст выглядит так:

``` swift
import Foundation

class Feed {

    public var cover: String
    public var link: String
    public var title: String
    public var creationTime: String

    init(data d: [String:Any]) {
        self.cover = d["cover"] as! String
        self.link = d["link"] as! String
        self.title = d["title"] as! String

        let secondsSince1970: Int = Int(d["creation_time"] as! String)!
        let creationDate = Date(timeIntervalSince1970: TimeInterval(secondsSince1970))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        self.creationTime = formatter.string(from: creationDate)
    }

}
```


Мы добавили новую переменную creationTime. Однако в json вместо даты нам прилетело какое-то большое число, что же не так? Это так называемый Unix Time. Это большое число отсчитывает количество секунд прошедших с 1 Января 1970 года. Это время еще называют «Эпохой Unix». Интересно как же в Unix Time будет 1950 год? Те кто подумал что это будет просто отрицательное число абсолютно правы! Однако не всё так просто и многие программы просто не расчитаны на подобные извращения. Поэтому если у кого-то есть iPhone под управлением iOS 8 или меньше и поломать его не жалко, то попробуйте выставить на нем время и дату час ночи 1 января 1970, а временной пояс поставить к примеру UTC +2:00. Получим 31 декабря 1969 года 23:00, а на этом мы получаем отрицательное значение и перезагрузив телефон получим кирпич😘. 

Еще один интересный факт. Тип переменной Integer ранее был ограничен вот так −2 147 483 648 до 2 147 483 647. Как вы думаете когда счетчик Unix-времени доберется до этих значений? А это время известно 19е января 2038 года в 4 часа ночи, 14 минут и 7 секунд. На самом деле проблему давно решили расширив этот диапозон.

Вернемся к нашему приложению. О том как работать с этим форматом подробнее узнаете в нашем теоретическом уроке. Сейчас же мы просто из этого огромного числа получим строку формата yyyy-MM-dd.

4. Теперь хотим как бы «научить» наш **UIImage** скачивать изображения по ссылке для отображения. Для этого нам понадобится инструмент extension, по-английски расширение. В swift вы можете легко создавать расширения для любых классов. Сегодня напишем расширение для **UIImage** и будет оно состоять из функции скачивания изображения с помощью известного уже нам **URLSession**. Создадим новый swift-файл и назовем его чтобы нам было понятно: **UIImageViewDownloadExtension.swift**. **Download Extension** для **UIImageView**. Текст в файле будет следующий:

``` swift
import UIKit

extension UIImageView {

    func downloadedFrom(link: String) {
        guard let url = URL(string: link) else { return }
        contentMode = .scaleAspectFill
        clipsToBounds = true
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
            else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
        }.resume()
    }

}
```

Разберем по строчно и по-русски как мы любим:
импортируем уже немного знакомый нам UIKit
объявляем что далее мы будем описывать расширение класса UIImageView
добавляем в расширение функцию downloadFrom, входящий параметр — link, строка.
объявляем переменную url, которая создается от класса URL, если же не получается его создать, то после else мы напишем return. Это к примеру если сервер нам почему-то вместо нормальной ссылки отдал к примеру пустую строку или строку заведомо не являющейся ссылкой, то есть такие: «12345», «qwerty», «привет!». Видно что запросив картинку по таким урлам мы уж точно изображение не получим, а вот зависнуть или сломаться можем.
далее мы описываем contentMode. Это описание режима отображения изображения в отведенном нами ему квадрате на экране. Поиграйтесь с этим параметром сами, его значения вы можете подсмотреть просто зажав CMD и кликнув на слово scaleAspectFill:
clipToBounds — этот параметр отвечает так же за отображение. Грубо говоря разрешено ли этому элементу выходить за свои границы визуально. true — значит не разрешено. false — можно.
Далее используем уже знакомый нам URLSession. Только теперь с полученными данными мы работаем не как с json, а как с изображением. 
5. Опишем то как теперь будут назначаться заголовок, дата и обложка. Добавим следующую функцию в наш FeedItem:
Теперь вместо назначения заголовка мы будем в качестве параметра задавать экземпляр класса Feed. А далее просто назначаем заголовок, изображение и дату. 
Осталось только вызвать это в FeedViewController вместо:
cell.setTitle(title: feeds[indexPath.row].title) 
Используем нашу новую функцию так:
cell.setFeed(feed: feeds[indexPath.row])



6. Мы хотим чтобы по нажатию на ячейку открывалась ссылка, которую отдал нам сервер. Давайте для этого в нашем классе Feed создадим новый метод openLink, который и будет открывать ссылку. Сама функция выглядит так:

``` swift
func openLink() {
    guard let url = URL(string: self.link) else {
        return
    }
    if UIApplication.shared.canOpenURL(url) {
        UIApplication.shared.open(url)
    }
}
```

Здесь стоит рассказать об объекте **UIApplication**. Если ссылаться на [документацию эппл](https://developer.apple.com/documentation/uikit/uiapplication) — это централизованная точка управления и координации приложений запущенных на **iOS**.

Вызывать мы её будем при нажатии на ячейку, добавим обработчик в FeedViewController. Вот так он выглядит:

``` swift
func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    feeds[indexPath.row].openLink()
}
```

И так в первой строке создаем обработчик события. Далее мы просто выбираем нужный нам Feed из массива feeds и вызываем из него метод, который мы только что написали.


7. Сделаем заголовок на экране **FeedViewController**.


Сверху добавим элемент **NavigationBar** получив заголовок, а нашу таблицу «приклеим» к нему с помощью констрейтов.8. Пользуясь мобильными приложениями вы уже наверно привыкли обновлять что-либо просто потянув вниз. В это время появляется анимированное изображение означающее загрузку. Это называется Pull to refresh, дословно: тяни чтобы обновить. Давайте добавим и мы этот инструмент в своё приложение. Сейчас вы поймете на сколько это просто😉. Для начала нам понадобится вынести код загрузки наших новостей в отдельную функцию, удаляем этот кусок из **viewDidLoad** и переносим в следующую функцию:

``` swift
@objc func reload() {
    refreshControl.beginRefreshing()
    let url = URL(string: «http://triangleye.com/bakh/lessons/swift/s7/")!
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    URLSession.shared.dataTask(with: request) {data, response, error in
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
        if (error != nil) {
            print("Server error is", error ?? "unknow")
            return
        }
        let responseJSON = try? JSONSerialization.jsonObject(with: data!, options: [])
        if let responseJSON = responseJSON as? [Any] {
            print(responseJSON)
            self.feeds.removeAll()
            for f in responseJSON {
                self.feeds.append(Feed(data: f as! [String:Any]))
            }
            DispatchQueue.main.async {
                self.feedList.reloadData()
            }
        } else {
            print("json error")
            // TODO: if server not json format response return standrd error json
        }
    }.resume()
}
```

Здесь у нас есть пара новых строк. Для начала разберем приставку @objc перед func reload(). Упрощая скажу, что эта приставка требуется тем функциям, которые должны быть видимыми для объектов Obj-C. Можно применить такую аналогию: public — означает, что функция видна всем объектам, private — означает, что функция видна только самому объекту, внутри которого и описывается, @objc — означает что видна объектам ObjC. К примеру разным селекторам, так как вызов этих функций зачастую идёт именно из таких объектов. Далее по коду поймете когда мы будем описывать переменную refreshControl. К слову здесь в начале мы пишем **refreshControl.beginRefreshing()** — это делается чтобы показалась анимация обновления, если вдруг её вызвали кодом, а не пользователь в ручную. 
Так же после того как нам пришел ответ от сервера нам надо сделать endRefreshing() чтоб анимация скрылась с экрана, так как это действие связано с UI, а мы находимся в асинхронной функции, то делать это надо в уже известном нам DispatchQueue.main.async. Если вы идете пошагово, то сейчас Xcode ругается на то что переменная refreshControl не существует, давайте удовлетворим его и опишем эту переменную.

``` swift
private lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(self, action: #selector(reload), for: UIControlEvents.valueChanged)
    return refreshControl
}()
```

В первой же строке видим целых 2 новых слова: lazy и UIRefreshControl. lazy — это такая переменная, которая не будет иницилизироваться, а соответственно не будет занимать нашу драгоценную память, до тех пор пока к ней не обратятся. UIRefreshControl — по приставке UI мы понимаем что это часть UserInterface, то есть визуальный компонент. Именно этот класс и отвечает за этот самый Pull to refresh.
Во второй строке мы просто его инициализируем. А далее мы указываем какую функцию следует вызвать при вызове нашего refreshControl, здесь то мы и видим ключевое слово #selector, для которого мы указали @objc. Объект готов и нам осталось его только добавить в наш TableView. Для этого модифицируем наш viewDidLoad и теперь она принимает следующий вид:

``` swift
override func viewDidLoad() {
super.viewDidLoad()
self.feedList.addSubview(refreshControl)
reload()
}
```

Добавим наш refreshControl в feedList с помощью функции addSubView. Ну и напишем reload() это вызовет скачивание наших новостей при загрузке FeedViewController, чтоб пользователю не пришлось делать это самостоятельно.9. Запустим и посмотрим, что получилось.

Уже симпатичнее не правда ли😍?


**Сейчас попробуйте по памяти все повторить, желательно 2-3 раза.**






