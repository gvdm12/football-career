class RealClubPlayer {
  final String name;
  final int age;
  final int overall;
  final int jerseyNumber;

  const RealClubPlayer(this.name, this.age, this.overall, this.jerseyNumber);
}

class RealClubSquads {
  const RealClubSquads._();

  // Составы топ-клубов сезона 2026/27. Рейтинги адаптированы под игру.
  static const Map<String, Map<String, List<RealClubPlayer>>> squads = {
    'Real Madrid': {
      'goalkeeper': [RealClubPlayer('Thibaut Courtois', 34, 90, 1), RealClubPlayer('Andriy Lunin', 27, 83, 13)],
      'defender': [RealClubPlayer('Dean Huijsen', 21, 84, 4), RealClubPlayer('Éder Militão', 28, 86, 3), RealClubPlayer('Trent Alexander-Arnold', 28, 87, 12), RealClubPlayer('Antonio Rüdiger', 33, 84, 22)],
      'midfielder': [RealClubPlayer('Jude Bellingham', 23, 91, 5), RealClubPlayer('Federico Valverde', 28, 90, 8), RealClubPlayer('Eduardo Camavinga', 23, 87, 6), RealClubPlayer('Aurélien Tchouaméni', 26, 86, 14)],
      'forward': [RealClubPlayer('Kylian Mbappé', 27, 94, 10), RealClubPlayer('Vinícius Júnior', 26, 92, 7), RealClubPlayer('Rodrygo', 25, 88, 11), RealClubPlayer('Endrick', 20, 82, 9)],
    },
    'Barcelona': {
      'goalkeeper': [RealClubPlayer('Joan García', 25, 86, 1), RealClubPlayer('Wojciech Szczęsny', 36, 82, 13)],
      'defender': [RealClubPlayer('Pau Cubarsí', 19, 87, 5), RealClubPlayer('Jules Koundé', 28, 87, 23), RealClubPlayer('Alejandro Balde', 23, 85, 3), RealClubPlayer('João Cancelo', 32, 83, 2)],
      'midfielder': [RealClubPlayer('Pedri', 23, 92, 8), RealClubPlayer('Gavi', 22, 87, 6), RealClubPlayer('Fermín López', 23, 86, 7), RealClubPlayer('Frenkie de Jong', 29, 87, 21)],
      'forward': [RealClubPlayer('Lamine Yamal', 19, 94, 10), RealClubPlayer('Raphinha', 29, 89, 11), RealClubPlayer('Karim Adeyemi', 24, 86, 14), RealClubPlayer('Anthony Gordon', 25, 86, 17)],
    },
    'PSG': {
      'goalkeeper': [RealClubPlayer('Lucas Chevalier', 25, 87, 30), RealClubPlayer('Matvey Safonov', 27, 84, 39)],
      'defender': [RealClubPlayer('Achraf Hakimi', 27, 88, 2), RealClubPlayer('Marquinhos', 32, 87, 5), RealClubPlayer('Nuno Mendes', 24, 89, 25), RealClubPlayer('Willian Pacho', 24, 87, 51)],
      'midfielder': [RealClubPlayer('Vitinha', 26, 90, 17), RealClubPlayer('João Neves', 22, 89, 87), RealClubPlayer('Fabián Ruiz', 30, 86, 8), RealClubPlayer('Warren Zaïre-Emery', 20, 86, 33)],
      'forward': [RealClubPlayer('Ousmane Dembélé', 29, 91, 10), RealClubPlayer('Khvicha Kvaratskhelia', 25, 90, 7), RealClubPlayer('Désiré Doué', 21, 88, 14), RealClubPlayer('Ferran Torres', 26, 85, 9)],
    },
    'Liverpool': {
      'goalkeeper': [RealClubPlayer('Alisson Becker', 34, 90, 1), RealClubPlayer('Giorgi Mamardashvili', 26, 86, 25)],
      'defender': [RealClubPlayer('Virgil van Dijk', 35, 89, 4), RealClubPlayer('Jérémy Jacquet', 21, 83, 5), RealClubPlayer('Milos Kerkez', 22, 85, 6), RealClubPlayer('Jeremie Frimpong', 25, 87, 30)],
      'midfielder': [RealClubPlayer('Florian Wirtz', 23, 91, 7), RealClubPlayer('Dominik Szoboszlai', 25, 88, 8), RealClubPlayer('Alexis Mac Allister', 27, 88, 10), RealClubPlayer('Ryan Gravenberch', 24, 87, 38)],
      'forward': [RealClubPlayer('Alexander Isak', 27, 90, 9), RealClubPlayer('Hugo Ekitike', 24, 87, 22), RealClubPlayer('Cody Gakpo', 27, 86, 18), RealClubPlayer('Bradley Barcola', 24, 88, 29)],
    },
    'Manchester City': {
      'goalkeeper': [RealClubPlayer('Gianluigi Donnarumma', 27, 90, 1), RealClubPlayer('Gerónimo Rulli', 34, 82, 28)],
      'defender': [RealClubPlayer('Rúben Dias', 29, 89, 3), RealClubPlayer('Marc Guéhi', 26, 86, 6), RealClubPlayer('Joško Gvardiol', 24, 89, 24), RealClubPlayer('Rayan Aït-Nouri', 25, 85, 21)],
      'midfielder': [RealClubPlayer('Phil Foden', 26, 90, 47), RealClubPlayer('Rayan Cherki', 23, 88, 10), RealClubPlayer('Enzo Fernández', 25, 87, 17), RealClubPlayer('Elliot Anderson', 23, 87, 5)],
      'forward': [RealClubPlayer('Erling Haaland', 26, 94, 9), RealClubPlayer('Jérémy Doku', 24, 87, 11), RealClubPlayer('Antoine Semenyo', 26, 87, 42), RealClubPlayer('Iliman Ndiaye', 26, 85, 7)],
    },
    'Bayern Munich': {
      'goalkeeper': [RealClubPlayer('Manuel Neuer', 40, 86, 1), RealClubPlayer('Jonas Urbig', 23, 82, 40)],
      'defender': [RealClubPlayer('Dayot Upamecano', 28, 87, 2), RealClubPlayer('Kim Min-jae', 30, 85, 3), RealClubPlayer('Jonathan Tah', 30, 87, 4), RealClubPlayer('Alphonso Davies', 25, 89, 19)],
      'midfielder': [RealClubPlayer('Joshua Kimmich', 31, 89, 6), RealClubPlayer('Jamal Musiala', 23, 92, 10), RealClubPlayer('Aleksandar Pavlović', 22, 85, 45), RealClubPlayer('Tom Bischof', 21, 82, 8)],
      'forward': [RealClubPlayer('Harry Kane', 33, 92, 9), RealClubPlayer('Michael Olise', 24, 90, 17), RealClubPlayer('Luis Díaz', 29, 89, 14), RealClubPlayer('Serge Gnabry', 31, 85, 7)],
    },
    'Arsenal': {
      'goalkeeper': [RealClubPlayer('David Raya', 31, 89, 1), RealClubPlayer('Kepa Arrizabalaga', 32, 82, 13)],
      'defender': [RealClubPlayer('William Saliba', 25, 90, 2), RealClubPlayer('Gabriel Magalhães', 28, 88, 6), RealClubPlayer('Jurriën Timber', 25, 87, 12), RealClubPlayer('Riccardo Calafiori', 24, 85, 33)],
      'midfielder': [RealClubPlayer('Declan Rice', 27, 91, 41), RealClubPlayer('Martin Ødegaard', 27, 89, 8), RealClubPlayer('Martín Zubimendi', 27, 87, 36), RealClubPlayer('Eberechi Eze', 28, 86, 10)],
      'forward': [RealClubPlayer('Bukayo Saka', 25, 91, 7), RealClubPlayer('Viktor Gyökeres', 28, 89, 14), RealClubPlayer('Kai Havertz', 27, 87, 29), RealClubPlayer('Noni Madueke', 24, 85, 20)],
    },
    'Atletico Madrid': {
      'goalkeeper': [RealClubPlayer('Jan Oblak', 33, 89, 13), RealClubPlayer('Juan Musso', 32, 83, 1)],
      'defender': [RealClubPlayer('David Hancko', 28, 86, 17), RealClubPlayer('Robin Le Normand', 30, 85, 24), RealClubPlayer('Marc Pubill', 23, 83, 18), RealClubPlayer('Marcos Llorente', 31, 86, 14)],
      'midfielder': [RealClubPlayer('Pablo Barrios', 23, 87, 8), RealClubPlayer('Koke', 34, 84, 6), RealClubPlayer('Johnny Cardoso', 25, 85, 5), RealClubPlayer('Conor Gallagher', 26, 85, 4)],
      'forward': [RealClubPlayer('Julián Álvarez', 26, 91, 19), RealClubPlayer('Alexander Sørloth', 30, 87, 9), RealClubPlayer('Ademola Lookman', 28, 87, 11), RealClubPlayer('Jonathan David', 26, 85, 15)],
    },
    'Inter': {
      'goalkeeper': [RealClubPlayer('Josep Martínez', 28, 84, 1), RealClubPlayer('Ivan Provedel', 32, 83, 49)],
      'defender': [RealClubPlayer('Alessandro Bastoni', 27, 89, 95), RealClubPlayer('John Stones', 32, 86, 6), RealClubPlayer('Manuel Akanji', 31, 86, 25), RealClubPlayer('Federico Dimarco', 28, 88, 32)],
      'midfielder': [RealClubPlayer('Nicolò Barella', 29, 90, 23), RealClubPlayer('Hakan Çalhanoğlu', 32, 88, 20), RealClubPlayer('Piotr Zieliński', 32, 85, 7), RealClubPlayer('Petar Sučić', 23, 84, 8)],
      'forward': [RealClubPlayer('Lautaro Martínez', 29, 91, 10), RealClubPlayer('Marcus Thuram', 29, 89, 9), RealClubPlayer('Ange-Yoan Bonny', 23, 84, 14), RealClubPlayer('Luis Henrique', 24, 84, 11)],
    },
    'Napoli': {
      'goalkeeper': [RealClubPlayer('Alex Meret', 29, 85, 1), RealClubPlayer('Vanja Milinković-Savić', 29, 84, 32)],
      'defender': [RealClubPlayer('Benoît Badiashile', 25, 84, 5), RealClubPlayer('Amir Rrahmani', 32, 85, 13), RealClubPlayer('Giovanni Di Lorenzo', 33, 86, 22), RealClubPlayer('Sam Beukema', 27, 84, 31)],
      'midfielder': [RealClubPlayer('Kevin De Bruyne', 35, 88, 11), RealClubPlayer('Scott McTominay', 29, 87, 8), RealClubPlayer('Stanislav Lobotka', 31, 86, 68), RealClubPlayer('Billy Gilmour', 25, 83, 6)],
      'forward': [RealClubPlayer('Rasmus Højlund', 23, 87, 19), RealClubPlayer('David Neres', 29, 85, 7), RealClubPlayer('Matteo Politano', 33, 84, 21), RealClubPlayer('Noa Lang', 27, 85, 70)],
    },
    'Tottenham': {
      'goalkeeper': [RealClubPlayer('Guglielmo Vicario', 30, 86, 1), RealClubPlayer('Antonín Kinský', 23, 80, 31)],
      'defender': [RealClubPlayer('Cristian Romero', 28, 88, 17), RealClubPlayer('Micky van de Ven', 25, 87, 37), RealClubPlayer('Pedro Porro', 27, 86, 23), RealClubPlayer('Destiny Udogie', 24, 84, 13)],
      'midfielder': [RealClubPlayer('James Maddison', 29, 86, 10), RealClubPlayer('Pape Matar Sarr', 24, 84, 29), RealClubPlayer('Dejan Kulusevski', 26, 87, 21), RealClubPlayer('Lucas Bergvall', 20, 83, 15)],
      'forward': [RealClubPlayer('Dominic Solanke', 29, 86, 19), RealClubPlayer('Richarlison', 29, 83, 9), RealClubPlayer('Brennan Johnson', 25, 84, 22), RealClubPlayer('Xavi Simons', 23, 87, 7)],
    },
    'Manchester United': {
      'goalkeeper': [RealClubPlayer('André Onana', 30, 84, 24), RealClubPlayer('Senne Lammens', 24, 81, 31)],
      'defender': [RealClubPlayer('Matthijs de Ligt', 27, 87, 4), RealClubPlayer('Lisandro Martínez', 28, 86, 6), RealClubPlayer('Harry Maguire', 33, 82, 5), RealClubPlayer('Diogo Dalot', 27, 85, 20)],
      'midfielder': [RealClubPlayer('Bruno Fernandes', 32, 90, 8), RealClubPlayer('Kobbie Mainoo', 21, 84, 37), RealClubPlayer('Casemiro', 34, 83, 18), RealClubPlayer('Mason Mount', 27, 83, 7)],
      'forward': [RealClubPlayer('Matheus Cunha', 27, 87, 10), RealClubPlayer('Bryan Mbeumo', 27, 87, 19), RealClubPlayer('Benjamin Šeško', 23, 86, 30), RealClubPlayer('Amad Diallo', 24, 85, 16)],
    },
    'Chelsea': {
      'goalkeeper': [RealClubPlayer('Robert Sánchez', 28, 83, 1), RealClubPlayer('Filip Jørgensen', 24, 81, 12)],
      'defender': [RealClubPlayer('Levi Colwill', 23, 85, 6), RealClubPlayer('Wesley Fofana', 25, 84,   fofanaNumber), RealClubPlayer('Reece James', 26, 87, 24), RealClubPlayer('Marc Cucurella', 27, 85, 3)],
      'midfielder': [RealClubPlayer('Enzo Fernández', 25, 88, 8), RealClubPlayer('Moisés Caicedo', 24, 89, 25), RealClubPlayer('Cole Palmer', 24, 91, 10), RealClubPlayer('Roméo Lavia', 22, 83, 45)],
      'forward': [RealClubPlayer('João Pedro', 25, 87, 20), RealClubPlayer('Liam Delap', 23, 83, 9), RealClubPlayer('Pedro Neto', 26, 86, 7), RealClubPlayer('Alejandro Garnacho', 22, 85, 49)],
    },
    'Borussia Dortmund': {
      'goalkeeper': [RealClubPlayer('Gregor Kobel', 28, 87, 1), RealClubPlayer('Alexander Meyer', 35, 78, 33)],
      'defender': [RealClubPlayer('Nico Schlotterbeck', 26, 87, 4), RealClubPlayer('Waldemar Anton', 30, 84, 3), RealClubPlayer('Niklas Süle', 31, 82, 25), RealClubPlayer('Julian Ryerson', 28, 83, 26)],
      'midfielder': [RealClubPlayer('Marcel Sabitzer', 32, 84, 20), RealClubPlayer('Felix Nmecha', 25, 84, 8), RealClubPlayer('Julian Brandt', 30, 86, 10), RealClubPlayer('Pascal Groß', 35, 82, 13)],
      'forward': [RealClubPlayer('Serhou Guirassy', 30, 88, 9), RealClubPlayer('Karim Adeyemi', 24, 86, 27), RealClubPlayer('Maximilian Beier', 24, 84, 14), RealClubPlayer('Jamie Gittens', 22, 84, 43)],
    },
    'Juventus': {
      'goalkeeper': [RealClubPlayer('Michele Di Gregorio', 29, 85, 29), RealClubPlayer('Mattia Perin', 33, 81, 1)],
      'defender': [RealClubPlayer('Bremer', 29, 88, 3), RealClubPlayer('Pierre Kalulu', 26, 84, 15), RealClubPlayer('Federico Gatti', 28, 83, 4), RealClubPlayer('Andrea Cambiaso', 26, 85, 27)],
      'midfielder': [RealClubPlayer('Manuel Locatelli', 28, 85, 5), RealClubPlayer('Khephren Thuram', 25, 86, 19), RealClubPlayer('Teun Koopmeiners', 28, 86, 8), RealClubPlayer('Weston McKennie', 28, 84, 22)],
      'forward': [RealClubPlayer('Dušan Vlahović', 26, 88, 9), RealClubPlayer('Kenan Yıldız', 21, 88, 10), RealClubPlayer('Francisco Conceição', 23, 85, 7), RealClubPlayer('Randal Kolo Muani', 27, 85, 20)],
    },
    'AC Milan': {
      'goalkeeper': [RealClubPlayer('Mike Maignan', 31, 88, 16), RealClubPlayer('Pietro Terracciano', 36, 79, 1)],
      'defender': [RealClubPlayer('Fikayo Tomori', 28, 84, 23), RealClubPlayer('Strahinja Pavlović', 25, 84, 31), RealClubPlayer('Matteo Gabbia', 26, 82, 46), RealClubPlayer('Theo Hernández', 29, 88, 19)],
      'midfielder': [RealClubPlayer('Youssouf Fofana', 27, 85, 29), RealClubPlayer('Luka Modrić', 41, 85, 14), RealClubPlayer('Ruben Loftus-Cheek', 30, 82, 8), RealClubPlayer('Tijjani Reijnders', 28, 87, 14)],
      'forward': [RealClubPlayer('Rafael Leão', 27, 90, 10), RealClubPlayer('Christian Pulisic', 28, 88, 11), RealClubPlayer('Santiago Giménez', 25, 85, 7), RealClubPlayer('Christopher Nkunku', 28, 85, 18)],
    },
    'Roma': {
      'goalkeeper': [RealClubPlayer('Mile Svilar', 27, 85, 99), RealClubPlayer('Pierluigi Gollini', 31, 78, 95)],
      'defender': [RealClubPlayer('Gianluca Mancini', 30, 84, 23), RealClubPlayer('Evan Ndicka', 27, 85, 5), RealClubPlayer('Mario Hermoso', 31, 83, 22), RealClubPlayer('Angeliño', 29, 84, 3)],
      'midfielder': [RealClubPlayer('Manu Koné', 25, 86, 17), RealClubPlayer('Bryan Cristante', 31, 83, 4), RealClubPlayer('Lorenzo Pellegrini', 30, 85, 7), RealClubPlayer('Niccolò Pisilli', 22, 81, 61)],
      'forward': [RealClubPlayer('Paulo Dybala', 32, 88, 21), RealClubPlayer('Artem Dovbyk', 29, 85, 11), RealClubPlayer('Matías Soulé', 23, 86, 18), RealClubPlayer('Stephan El Shaarawy', 33, 81, 92)],
    },
  };
}
