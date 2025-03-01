import UIKit

/// Конфигурация ячейки. Содержит данные для отображения в ячейке.
struct ReviewCellConfig {

    /// Идентификатор для переиспользования ячейки.
    static let reuseId = String(describing: ReviewCellConfig.self)

    /// Идентификатор конфигурации. Можно использовать для поиска конфигурации в массиве.
    let id: UUID
    /// Имя пользователя.
    let username: NSAttributedString
    /// Текст отзыва.
    let reviewText: NSAttributedString
    /// Рейтинг отзыва.
    let raitingImage: UIImage
    /// Фотографии отзыва.
    var photosState: [ImageState]
    /// Максимальное отображаемое количество строк текста. По умолчанию 3.
    var maxLines = 3
    /// Время создания отзыва.
    let created: NSAttributedString
    /// Замыкание, вызываемое при нажатии на кнопку "Показать полностью...".
    let onTapShowMore: (UUID) -> Void

    /// Объект, хранящий посчитанные фреймы для ячейки отзыва.
    fileprivate let layout = ReviewCellLayout()

}

// MARK: - Identifiable & Hashable & Equatable

extension ReviewCellConfig: Identifiable, Hashable, Equatable {

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(username)
        hasher.combine(reviewText)
        hasher.combine(raitingImage)
        hasher.combine(photosState)
        hasher.combine(maxLines)
        hasher.combine(created)
    }

    static func == (lhs: ReviewCellConfig, rhs: ReviewCellConfig) -> Bool {
        lhs.id == rhs.id
        && lhs.username == rhs.username
        && lhs.reviewText == rhs.reviewText
        && lhs.raitingImage == rhs.raitingImage
        && lhs.photosState == rhs.photosState
        && lhs.maxLines == rhs.maxLines
        && lhs.created == rhs.created
    }

}

// MARK: - TableCellConfig

extension ReviewCellConfig: TableCellConfig {

    /// Метод обновления ячейки.
    /// Вызывается из `cellForRowAt:` у `dataSource` таблицы.
    func update(cell: UITableViewCell) {
        guard
            let cell = cell as? ReviewCell,
            cell.config != self
        else { return }

        cell.setPhotos(with: photosState)
        cell.ratingImageView.image = raitingImage
        cell.nameLable.attributedText = username
        cell.reviewTextLabel.attributedText = reviewText
        cell.reviewTextLabel.numberOfLines = maxLines
        cell.createdLabel.attributedText = created
        cell.config = self
    }

    /// Метод, возвращаюший высоту ячейки с данным ограничением по размеру.
    /// Вызывается из `heightForRowAt:` делегата таблицы.
    func height(with size: CGSize) -> CGFloat {
        layout.height(config: self, maxWidth: size.width)
    }

}

// MARK: - Private

private extension ReviewCellConfig {

    /// Текст кнопки "Показать полностью...".
    static let showMoreText = "Показать полностью..."
        .attributed(font: .showMore, color: .showMore)

}

// MARK: - Cell

final class ReviewCell: UITableViewCell {

    fileprivate var config: Config?

    fileprivate let ratingImageView = UIImageView()
    fileprivate let nameLable = UILabel()
    fileprivate let avatarImageView = UIImageView()
    fileprivate let reviewTextLabel = UILabel()
    fileprivate let createdLabel = UILabel()
    fileprivate let showMoreButton = UIButton()
    fileprivate var photosView = [ReviewPhotoView]()

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        guard let layout = config?.layout else { return }
        nameLable.frame = layout.nameLableFrame
        ratingImageView.frame = layout.ratingImageViewFrame
        avatarImageView.frame = layout.avatarImageViewFrame
        reviewTextLabel.frame = layout.reviewTextLabelFrame
        createdLabel.frame = layout.createdLabelFrame
        showMoreButton.frame = layout.showMoreButtonFrame

        for index in 0..<photosView.count {
            guard index < layout.photosFrames.count else { break }
            photosView[index].frame = layout.photosFrames[index]
        }
    }

    func setPhotos(with imageStates: [ImageState]) {
        guard imageStates != config?.photosState else {
            return
        }

        // Скрываем все старые вью перед обновлением
        for photoView in photosView {
            photoView.isHidden = true
        }

        // Добавляем новые фотографии или обновляем существующие
        for (index, imageState) in imageStates.enumerated() {
            if index < photosView.count {
                // Если вью уже есть, обновляем картинку и показываем её
                let photoView = photosView[index]
                photoView.updateImage(with: imageState)
                photoView.isHidden = false
            } else {
                // Если не хватает вью, создаём новые
                let photoView = makeReviewPhotoView(for: imageState)
                photoView.tag = index
                contentView.addSubview(photoView)
                photosView.append(photoView)
            }
        }

        // Скрыть лишние фото, если их стало меньше, чем было раньше
        if imageStates.count < photosView.count {
            for index in imageStates.count..<photosView.count {
                photosView[index].isHidden = true
            }
        }

        setNeedsLayout()
    }

}

// MARK: - Private

private extension ReviewCell {

    func setupCell() {
        setupNameLabel()
        setupRatingImage()
        setupAvatarImageView()
        setupReviewTextLabel()
        setupCreatedLabel()
        setupShowMoreButton()
        addAction()
    }

    func setupNameLabel() {
        contentView.addSubview(nameLable)
    }

    func setupRatingImage() {
        contentView.addSubview(ratingImageView)
    }

    func makeReviewPhotoView(for imageState: ImageState) -> ReviewPhotoView {
        let photoView = ReviewPhotoView(imageState: imageState)
        photoView.layer.cornerRadius = ReviewCellLayout.photoCornerRadius
        photoView.layer.masksToBounds = true
        return photoView
    }

    func setupAvatarImageView() {
        contentView.addSubview(avatarImageView)
        avatarImageView.image = UIImage(resource: .l5W5AIHioYc)
        avatarImageView.layer.cornerRadius = ReviewCellLayout.avatarCornerRadius
        avatarImageView.layer.masksToBounds = true
    }

    func setupReviewTextLabel() {
        contentView.addSubview(reviewTextLabel)
        reviewTextLabel.lineBreakMode = .byWordWrapping
    }

    func setupCreatedLabel() {
        contentView.addSubview(createdLabel)
    }

    func setupShowMoreButton() {
        contentView.addSubview(showMoreButton)
        showMoreButton.contentVerticalAlignment = .fill
        showMoreButton.setAttributedTitle(Config.showMoreText, for: .normal)
    }

    func addAction() {
        let action = UIAction { [weak self] _ in
            guard let self, let config else { return }
            config.onTapShowMore(config.id)
        }
        showMoreButton.addAction(action, for: .touchUpInside)
    }

}

// MARK: - Layout

/// Класс, в котором происходит расчёт фреймов для сабвью ячейки отзыва.
/// После расчётов возвращается актуальная высота ячейки.
private final class ReviewCellLayout {

    // MARK: - Размеры

    fileprivate static let avatarSize = CGSize(width: 36.0, height: 36.0)
    fileprivate static let avatarCornerRadius = 18.0
    fileprivate static let photoCornerRadius = 8.0

    private static let photoSize = CGSize(width: 55.0, height: 66.0)
    private static let showMoreButtonSize = Config.showMoreText.size()

    // MARK: - Фреймы

    private(set) var nameLableFrame = CGRect.zero
    private(set) var ratingImageViewFrame = CGRect.zero
    private(set) var avatarImageViewFrame = CGRect.zero
    private(set) var photosFrames = [CGRect]()
    private(set) var reviewTextLabelFrame = CGRect.zero
    private(set) var showMoreButtonFrame = CGRect.zero
    private(set) var createdLabelFrame = CGRect.zero

    // MARK: - Отступы

    /// Отступы от краёв ячейки до её содержимого.
    private let insets = UIEdgeInsets(top: 9.0, left: 12.0, bottom: 9.0, right: 12.0)

    /// Горизонтальный отступ от аватара до имени пользователя.
    private let avatarToUsernameSpacing = 10.0
    /// Вертикальный отступ от имени пользователя до вью рейтинга.
    private let usernameToRatingSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до текста (если нет фото).
    private let ratingToTextSpacing = 6.0
    /// Вертикальный отступ от вью рейтинга до фото.
    private let ratingToPhotosSpacing = 10.0
    /// Горизонтальные отступы между фото.
    private let photosSpacing = 8.0
    /// Вертикальный отступ от фото (если они есть) до текста отзыва.
    private let photosToTextSpacing = 10.0
    /// Вертикальный отступ от текста отзыва до времени создания отзыва или кнопки "Показать полностью..." (если она есть).
    private let reviewTextToCreatedSpacing = 6.0
    /// Вертикальный отступ от кнопки "Показать полностью..." до времени создания отзыва.
    private let showMoreToCreatedSpacing = 6.0

    // MARK: - Расчёт фреймов и высоты ячейки

    /// Возвращает высоту ячейку с данной конфигурацией `config` и ограничением по ширине `maxWidth`.
    func height(config: Config, maxWidth: CGFloat) -> CGFloat {
        let width = maxWidth - insets.left - insets.right - Self.avatarSize.width - avatarToUsernameSpacing
        let contentXPosition: CGFloat = insets.left + Self.avatarSize.width + avatarToUsernameSpacing

        var maxY = insets.top
        var showShowMoreButton = false

        avatarImageViewFrame = CGRect(
            origin: CGPoint(x: insets.left, y: insets.top),
            size: Self.avatarSize
        )

        nameLableFrame = CGRect(
            origin: CGPoint(x: contentXPosition, y: insets.top),
            size: config.username.boundingRect(width: width).size
        )

        ratingImageViewFrame = CGRect(
            origin: CGPoint(x: contentXPosition, y: nameLableFrame.maxY + usernameToRatingSpacing),
            size: config.raitingImage.size
        )

        photosFrames = config.photosState.enumerated().map { index, _ in
            CGRect(
                origin: CGPoint(
                    x: contentXPosition + Self.photoSize.width * CGFloat(index) + CGFloat(index) * photosSpacing,
                    y: ratingImageViewFrame.maxY + ratingToPhotosSpacing
                ),
                size: CGSize(
                    width: Self.photoSize.width,
                    height: Self.photoSize.height
                )
            )
        }
        let photosMaxY = photosFrames.last?.maxY ?? ratingImageViewFrame.maxY

        if !config.reviewText.isEmpty() {
            // Высота текста с текущим ограничением по количеству строк.
            let currentTextHeight = (config.reviewText.font()?.lineHeight ?? .zero) * CGFloat(config.maxLines)
            // Максимально возможная высота текста, если бы ограничения не было.
            let actualTextHeight = config.reviewText.boundingRect(width: width).size.height
            // Показываем кнопку "Показать полностью...", если максимально возможная высота текста больше текущей.
            showShowMoreButton = config.maxLines != .zero && actualTextHeight > currentTextHeight

            reviewTextLabelFrame = CGRect(
                origin: CGPoint(
                    x: contentXPosition,
                    // FIXME: ratingToTextSpacing подумать если есть фото
                    y: photosMaxY + ratingToTextSpacing
                ),
                size: config.reviewText.boundingRect(width: width, height: currentTextHeight).size
            )
            maxY = reviewTextLabelFrame.maxY + reviewTextToCreatedSpacing
        } else {
            // FIXME: Тут ещё отступ добваить бы
            maxY = photosMaxY + reviewTextToCreatedSpacing
        }

        if showShowMoreButton {
            showMoreButtonFrame = CGRect(
                origin: CGPoint(x: contentXPosition, y: maxY),
                size: Self.showMoreButtonSize
            )
            maxY = showMoreButtonFrame.maxY + showMoreToCreatedSpacing
        } else {
            showMoreButtonFrame = .zero
        }

        createdLabelFrame = CGRect(
            origin: CGPoint(x: contentXPosition, y: maxY),
            size: config.created.boundingRect(width: width).size
        )

        return createdLabelFrame.maxY + insets.bottom
    }

}

// MARK: - Typealias

fileprivate typealias Config = ReviewCellConfig
fileprivate typealias Layout = ReviewCellLayout
