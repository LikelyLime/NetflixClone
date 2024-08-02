//
//  MainViewModel.swift
//  NetflixClone
//
//  Created by 백시훈 on 8/1/24.
//

import Foundation
import RxSwift
class MainViewModel{
    
    private let apiKey = "7e402754daa3c054fc5557de4adb7d70"
    private let disposeBag = DisposeBag()
    
    let popularMovieSubject = BehaviorSubject(value: [Movie]())
    let topRatedMovieSsubject = BehaviorSubject(value: [Movie]())
    let upcomingMovieSubject = BehaviorSubject(value: [Movie]())
    
    init(){
        fetchPopularMovie()
        fetchTopRatedMovie()
        fetchUpcomingMovie()
    }
    ///popular Movie 데이터를 서버로 부터 불러온다.
    /// ViewModel에서 수행해야하는 비즈니스 로직
    func fetchPopularMovie(){
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/popular?api_key=\(apiKey)") else{
            popularMovieSubject.onError(NetworkError.invailedUrl)
            return
        }
        NetworkManager.shared.fetch(url: url).subscribe(onSuccess: { [weak self] (movieResponse: MovieResponse) in
            self?.popularMovieSubject.onNext(movieResponse.results)
        }, onFailure: { [weak self] error in
            self?.popularMovieSubject.onError(error)
        }).disposed(by: disposeBag)
    }
    
    func fetchTopRatedMovie(){
        //1. Url 선언
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/top_rated?api_key=\(apiKey)") else{
            topRatedMovieSsubject.onError(NetworkError.invailedUrl)
            return
        }
        
        //2. 네트워크 매니저 연결
        NetworkManager.shared.fetch(url: url).subscribe(onSuccess: { [weak self] (movieResponse: MovieResponse) in
            self?.topRatedMovieSsubject.onNext(movieResponse.results)
        }, onFailure: { [weak self] error in
            self?.topRatedMovieSsubject.onError(error)
        }).disposed(by: disposeBag)
    }
    
    func fetchUpcomingMovie(){
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/upcoming?api_key=\(apiKey)") else{
            upcomingMovieSubject.onError(NetworkError.invailedUrl)
            return
        }
        NetworkManager.shared.fetch(url: url).subscribe(onSuccess: { [weak self] (movieResponse: MovieResponse) in
            self?.upcomingMovieSubject.onNext(movieResponse.results)
        }, onFailure: { [weak self] error in
            self?.upcomingMovieSubject.onError(error)
        }).disposed(by: disposeBag)
    }
    
    ///동영상 키 값을 가져오는 메서드
    func fetchTrailerKey(movie: Movie) -> Single<String>{
        guard let movieId = movie.id else{ return Single.error(NetworkError.dataFetchFail) }
        let urlString = "https://api.themoviedb.org/3/movie/\(movieId)/videos?api_key=\(apiKey)"
        guard let url = URL(string: urlString) else{
            return Single.error(NetworkError.invailedUrl)
        }
        return NetworkManager.shared.fetch(url: url) //flatmap를 이용하여  Single<VideoResponse>를 Single<String>으로 변경
            .flatMap { (VideoResponse: VideoResponse) -> Single<String> in
                if let trailer = VideoResponse.results.first(where: { $0.type == "Trailer" && $0.site == "YouTube"} ){
                    guard let key = trailer.key else { return Single.error(NetworkError.dataFetchFail) }
                    return Single.just(key)
                }else{
                    return Single.error(NetworkError.dataFetchFail)
                }
            }
    }
}
