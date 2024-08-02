//
//  ViewController.swift
//  NetflixClone
//
//  Created by 백시훈 on 8/1/24.
//

import UIKit
import SnapKit
import RxSwift
import AVKit
import AVFoundation
class MainViewController: UIViewController {
    private let viewModel = MainViewModel()
    private let disposeBag = DisposeBag()
    private var popularMovies = [Movie]()
    private var topRatedMovies = [Movie]()
    private var upcomingMovies = [Movie]()
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "NETFLIX"
        label.textColor = UIColor(red: 229/255, green: 9/255, blue: 20/255, alpha: 1.0)
        label.font = UIFont.systemFont(ofSize: 28, weight: .heavy)
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: createLayout())
        collectionView.register(PosterCell.self, forCellWithReuseIdentifier: PosterCell.id)
        collectionView.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: SectionHeaderView.id)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = .black
        return collectionView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        bind()
        configureUI()
    }
    
    func bind(){
        viewModel.popularMovieSubject.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] movies in
            self?.popularMovies = movies
            self?.collectionView.reloadData()
        }, onError: { [weak self] error in
            print(error)
        }).disposed(by: disposeBag)
        
        viewModel.topRatedMovieSsubject.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] movies in
            self?.topRatedMovies = movies
            self?.collectionView.reloadData()
        }, onError: { [weak self] error in
            print(error)
        }).disposed(by: disposeBag)
        
        viewModel.upcomingMovieSubject.observe(on: MainScheduler.instance).subscribe(onNext: { [weak self] movies in
            self?.upcomingMovies = movies
            self?.collectionView.reloadData()
        }, onError: { [weak self] error in
            print(error)
        }).disposed(by: disposeBag)
    }
    
    private func createLayout() -> UICollectionViewLayout{
        // 각 아이템이 각 그룹 내에서 전체 넓이와 전체 높이를 차지. 1.0 = 100%
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0))
        
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        
        // 각 그룹 넓이는 화면 넓이의 25% 를 차지하고, 높이는 넓이의 40%
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25), heightDimension: .fractionalWidth(0.4))
        
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
        
        let section = NSCollectionLayoutSection(group: group)
        section.orthogonalScrollingBehavior = .continuous
        section.interGroupSpacing = 10
        section.contentInsets = .init(top: 10, leading: 10, bottom: 20, trailing: 10)
        
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        
        section.boundarySupplementaryItems = [header]
        
        return UICollectionViewCompositionalLayout(section: section)
    }
    
    private func configureUI(){
        view.backgroundColor = .black
        [
            label,
            collectionView
        ].forEach { view.addSubview($0) }
        
        label.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(10)
            $0.leading.equalTo(view.safeAreaLayoutGuide.snp.leading).inset(10)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(label.snp.top).offset(40)
            $0.horizontalEdges.equalTo(view.safeAreaLayoutGuide.snp.horizontalEdges)
            $0.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
    }
    
    private func playVideoUrl(){
        
        //TMBC에서 제공하는 URL은 실행 시킬 수 없음으로 대체
        //유튜브 url의 경우에는 정책상 바로 실행할 수 없음
        let url = URL(string: "https://storage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4")!
        
        let player = AVPlayer(url: url)
        
        //AVPlayer를 controller에 넣으면 동영상을 실행 시킬수 있는 새로운 화면을 열수 있다.
        let playerViewController = AVPlayerViewController()
        
        playerViewController.player = player
        present(playerViewController, animated: true){
            player.play()
        }
        
    }
    
}

enum Section: Int, CaseIterable{
    case popularMovies
    case topRatedMovies
    case upcomingMovies
    
    var title: String{
        switch self{
            case.popularMovies: return "이 시간 핫한 영화"
            case.topRatedMovies: return "가장 평점이 높은 영화"
            case.upcomingMovies: return "곧 개봉되는 영화"
        }
    }
    
}

extension MainViewController: UICollectionViewDelegate{
    
    //아이템을 클릭했을때 반응하는 메서드
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch Section(rawValue: indexPath.section){
            case .popularMovies:
                viewModel.fetchTrailerKey(movie: popularMovies[indexPath.row])
                    .observe(on: MainScheduler.instance)
                    .subscribe (onSuccess: { [weak self] key in
                        //self?.playVideoUrl()
                        self?.navigationController?.pushViewController(YoutubeViewController(key: key), animated: true)
                    }, onError: { error in
                        print("에러발생 : \(error)")
                    }).disposed(by: disposeBag)
            case .topRatedMovies:
                viewModel.fetchTrailerKey(movie: topRatedMovies[indexPath.row])
                    .observe(on: MainScheduler.instance)
                    .subscribe (onSuccess: { [weak self] key in
                        //self?.playVideoUrl()
                        self?.navigationController?.pushViewController(YoutubeViewController(key: key), animated: true)
                    }, onError: { error in
                        print("에러발생 : \(error)")
                    }).disposed(by: disposeBag)
            case .upcomingMovies:
                viewModel.fetchTrailerKey(movie: upcomingMovies[indexPath.row])
                    .observe(on: MainScheduler.instance)
                    .subscribe (onSuccess: { [weak self] key in
                        //self?.playVideoUrl()
                        self?.navigationController?.pushViewController(YoutubeViewController(key: key), animated: true)
                    }, onError: { error in
                        print("에러발생 : \(error)")
                    }).disposed(by: disposeBag)
            default:
                return

        }
    }
}
extension MainViewController: UICollectionViewDataSource{
    //indexPath별로 cell을 구현하는 부분
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch Section(rawValue: section){
            case .popularMovies: return popularMovies.count
            case .topRatedMovies: return topRatedMovies.count
            case .upcomingMovies: return upcomingMovies.count
            default: return 0
        }
    
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PosterCell.id, for: indexPath) as? PosterCell else{
            return UICollectionViewCell()
        }
        
        switch Section(rawValue: indexPath.section){
            case .popularMovies:
                cell.configure(with: popularMovies[indexPath.row])
            case .topRatedMovies:
                cell.configure(with: topRatedMovies[indexPath.row])
            case .upcomingMovies:
                cell.configure(with: upcomingMovies[indexPath.row])
            default:
                return UICollectionViewCell()
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else{
            return UICollectionReusableView()
        }
        
        guard let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SectionHeaderView.id, for: indexPath) as? SectionHeaderView else {
            return UICollectionReusableView()
        }
        
        let sectionType = Section.allCases[indexPath.row]
        headerView.configure(with: sectionType.title)
        return headerView
    }
    
    // collectionView의 색션이 몇개인지 설정하는 메서드
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return Section.allCases.count
    }
    
}