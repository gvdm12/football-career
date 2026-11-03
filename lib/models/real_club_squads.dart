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
      'goalkeeper': [
        RealClubPlayer('Thibaut Courtois', 34, 90, 1),
        RealClubPlayer('Andriy Lunin', 27, 83, 13),
      ],
      'defender': [
        RealClubPlayer('Dean Huijsen', 21, 84, 4),
        RealClubPlayer('Éder Militão', 28, 86, 3),
        RealClubPlayer('Trent Alexander-Arnold', 28, 87, 12),
        RealClubPlayer('Antonio Rüdiger', 33, 84, 22),
      ],
      'midfielder': [
        RealClubPlayer('Jude Bellingham', 23, 91, 5),
        RealClubPlayer('Federico Valverde', 28, 90, 8),
        RealClubPlayer('Arda Guler', 21, 88, 15),
        RealClubPlayer('Aurélien Tchouaméni', 26, 86, 14),
      ],
      'forward': [
        RealClubPlayer('Kylian Mbappé', 27, 93, 10),
        RealClubPlayer('Vinícius Júnior', 26, 87, 7),
        RealClubPlayer('Rodrygo', 25, 86, 11),
        RealClubPlayer('Diomande', 20, 86, 25),
      ],
    },
    'Barcelona': {
      'goalkeeper': [
        RealClubPlayer('Joan García', 25, 86, 1),
        RealClubPlayer('Wojciech Szczęsny', 36, 82, 13),
      ],
      'defender': [
        RealClubPlayer('Pau Cubarsí', 19, 87, 5),
        RealClubPlayer('Jules Koundé', 28, 87, 23),
        RealClubPlayer('Alejandro Balde', 23, 85, 3),
        RealClubPlayer('João Cancelo', 32, 83, 2),
      ],
      'midfielder': [
        RealClubPlayer('Pedri', 23, 90, 8),
        RealClubPlayer('Gavi', 22, 87, 6),
        RealClubPlayer('Fermín López', 23, 86, 7),
        RealClubPlayer('Frenkie de Jong', 29, 87, 21),
      ],
      'forward': [
        RealClubPlayer('Lamine Yamal', 19, 89, 10),
        RealClubPlayer('Raphinha', 29, 91, 11),
        RealClubPlayer('Karim Adeyemi', 24, 86, 14),
        RealClubPlayer('Anthony Gordon', 25, 86, 17),
      ],
    },
    'PSG': {
      'goalkeeper': [
        RealClubPlayer('Lucas Chevalier', 25, 87, 30),
        RealClubPlayer('Matvey Safonov', 27, 84, 39),
      ],
      'defender': [
        RealClubPlayer('Achraf Hakimi', 27, 88, 2),
        RealClubPlayer('Marquinhos', 32, 87, 5),
        RealClubPlayer('Nuno Mendes', 24, 89, 25),
        RealClubPlayer('Willian Pacho', 24, 87, 51),
      ],
      'midfielder': [
        RealClubPlayer('Vitinha', 26, 90, 17),
        RealClubPlayer('João Neves', 22, 89, 87),
        RealClubPlayer('Fabián Ruiz', 30, 86, 8),
        RealClubPlayer('Warren Zaïre-Emery', 20, 86, 33),
      ],
      'forward': [
        RealClubPlayer('Ousmane Dembélé', 29, 91, 10),
        RealClubPlayer('Khvicha Kvaratskhelia', 25, 90, 7),
        RealClubPlayer('Désiré Doué', 21, 88, 14),
        RealClubPlayer('Ferran Torres', 26, 85, 9),
      , RealClubPlayer('Mika Godts', 21, 84, 22)],
    },
    'Liverpool': {
      'goalkeeper': [
        RealClubPlayer('Alisson Becker', 34, 90, 1),
        RealClubPlayer('Giorgi Mamardashvili', 26, 86, 25),
      ],
      'defender': [
        RealClubPlayer('Virgil van Dijk', 35, 89, 4),
        RealClubPlayer('Jérémy Jacquet', 21, 83, 5),
        RealClubPlayer('Milos Kerkez', 22, 85, 6),
        RealClubPlayer('Jeremie Frimpong', 25, 87, 30),
      ],
      'midfielder': [
        RealClubPlayer('Florian Wirtz', 23, 89, 7),
        RealClubPlayer('Dominik Szoboszlai', 25, 88, 8),
        RealClubPlayer('Alexis Mac Allister', 27, 88, 10),
        RealClubPlayer('Ryan Gravenberch', 24, 87, 38),
      ],
      'forward': [
        RealClubPlayer('Alexander Isak', 27, 87, 9),
        RealClubPlayer('Hugo Ekitike', 24, 87, 22),
        RealClubPlayer('Cody Gakpo', 27, 86, 18),
        RealClubPlayer('Bradley Barcola', 24, 88, 29),
      ],
    },
    'Manchester City': {
      'goalkeeper': [
        RealClubPlayer('Gianluigi Donnarumma', 27, 90, 1),
        RealClubPlayer('Gerónimo Rulli', 34, 82, 28),
      ],
      'defender': [
        RealClubPlayer('Rúben Dias', 29, 89, 3),
        RealClubPlayer('Marc Guéhi', 26, 86, 6),
        RealClubPlayer('Joško Gvardiol', 24, 89, 24),
        RealClubPlayer('Rayan Aït-Nouri', 25, 85, 21),
      ],
      'midfielder': [
        RealClubPlayer('Phil Foden', 26, 87, 47),
        RealClubPlayer('Rayan Cherki', 23, 88, 10),
        RealClubPlayer('Enzo Fernández', 25, 87, 17),
        RealClubPlayer('Elliot Anderson', 23, 85, 5),
      ],
      'forward': [
        RealClubPlayer('Erling Haaland', 26, 94, 9),
        RealClubPlayer('Jérémy Doku', 24, 87, 11),
        RealClubPlayer('Antoine Semenyo', 26, 85, 42),
        RealClubPlayer('Iliman Ndiaye', 26, 84, 7),
      ],
    },
    'Bayern Munich': {
      'goalkeeper': [
        RealClubPlayer('Manuel Neuer', 40, 86, 1),
        RealClubPlayer('Jonas Urbig', 23, 82, 40),
      ],
      'defender': [
        RealClubPlayer('Dayot Upamecano', 28, 87, 2),
        RealClubPlayer('Kim Min-jae', 30, 85, 3),
        RealClubPlayer('Jonathan Tah', 30, 87, 4),
        RealClubPlayer('Alphonso Davies', 25, 89, 19),
      ],
      'midfielder': [
        RealClubPlayer('Joshua Kimmich', 31, 89, 6),
        RealClubPlayer('Jamal Musiala', 23, 92, 10),
        RealClubPlayer('Aleksandar Pavlović', 22, 85, 45),
        RealClubPlayer('Tom Bischof', 21, 82, 8),
      ],
      'forward': [
        RealClubPlayer('Harry Kane', 33, 92, 9),
        RealClubPlayer('Michael Olise', 24, 90, 17),
        RealClubPlayer('Luis Díaz', 29, 89, 14),
        RealClubPlayer('Serge Gnabry', 31, 85, 7),
      ],
    },
    'Arsenal': {
      'goalkeeper': [
        RealClubPlayer('David Raya', 31, 89, 1),
        RealClubPlayer('Kepa Arrizabalaga', 32, 82, 13),
      ],
      'defender': [
        RealClubPlayer('William Saliba', 25, 90, 2),
        RealClubPlayer('Gabriel Magalhães', 28, 88, 6),
        RealClubPlayer('Jurriën Timber', 25, 87, 12),
        RealClubPlayer('Riccardo Calafiori', 24, 85, 33),
      ],
      'midfielder': [
        RealClubPlayer('Declan Rice', 27, 90, 41),
        RealClubPlayer('Martin Ødegaard', 27, 89, 8),
        RealClubPlayer('Martín Zubimendi', 27, 87, 36),
        RealClubPlayer('Eberechi Eze', 28, 86, 10),
      ],
      'forward': [
        RealClubPlayer('Bukayo Saka', 25, 88, 7),
        RealClubPlayer('Viktor Gyökeres', 28, 87, 14),
        RealClubPlayer('Kai Havertz', 27, 86, 29),
        RealClubPlayer('Noni Madueke', 24, 85, 20),
      ],
    },
    'Atletico Madrid': {
      'goalkeeper': [
        RealClubPlayer('Jan Oblak', 33, 89, 13),
        RealClubPlayer('Juan Musso', 32, 83, 1),
      ],
      'defender': [
        RealClubPlayer('David Hancko', 28, 86, 17),
        RealClubPlayer('Robin Le Normand', 30, 85, 24),
        RealClubPlayer('Marc Pubill', 23, 83, 18),
        RealClubPlayer('Marcos Llorente', 31, 86, 14),
      ],
      'midfielder': [
        RealClubPlayer('Pablo Barrios', 23, 87, 8),
        RealClubPlayer('Koke', 34, 84, 6),
        RealClubPlayer('Johnny Cardoso', 25, 85, 5),
        RealClubPlayer('Lee Kang-In', 25, 85, 7),
      ],
      'forward': [
        RealClubPlayer('Julián Álvarez', 26, 89, 19),
        RealClubPlayer('Alexander Sørloth', 30, 85, 9),
        RealClubPlayer('Ademola Lookman', 28, 86, 11),
        RealClubPlayer('Jonathan David', 26, 85, 15),
      ],
    },
    'Inter': {
      'goalkeeper': [
        RealClubPlayer('Josep Martínez', 28, 84, 1),
        RealClubPlayer('Ivan Provedel', 32, 83, 49),
      ],
      'defender': [
        RealClubPlayer('Alessandro Bastoni', 27, 89, 95),
        RealClubPlayer('John Stones', 32, 86, 6),
        RealClubPlayer('Manuel Akanji', 31, 86, 25),
        RealClubPlayer('Federico Dimarco', 28, 88, 32),
      ],
      'midfielder': [
        RealClubPlayer('Nicolò Barella', 29, 87, 23),
        RealClubPlayer('Hakan Çalhanoğlu', 32, 87, 20),
        RealClubPlayer('Piotr Zieliński', 32, 85, 7),
        RealClubPlayer('Petar Sučić', 23, 84, 8),
      ],
      'forward': [
        RealClubPlayer('Lautaro Martínez', 29, 90, 10),
        RealClubPlayer('Marcus Thuram', 29, 86, 9),
        RealClubPlayer('Ange-Yoan Bonny', 23, 84, 14),
        RealClubPlayer('Luis Henrique', 24, 84, 11),
      ],
    },
    'Napoli': {
      'goalkeeper': [
        RealClubPlayer('Alex Meret', 29, 85, 1),
        RealClubPlayer('Vanja Milinković-Savić', 29, 84, 32),
      ],
      'defender': [
        RealClubPlayer('Benoît Badiashile', 25, 84, 5),
        RealClubPlayer('Amir Rrahmani', 32, 85, 13),
        RealClubPlayer('Giovanni Di Lorenzo', 33, 86, 22),
        RealClubPlayer('Sam Beukema', 27, 84, 31),
      ],
      'midfielder': [
        RealClubPlayer('Kevin De Bruyne', 35, 88, 11),
        RealClubPlayer('Scott McTominay', 29, 87, 8),
        RealClubPlayer('Stanislav Lobotka', 31, 86, 68),
        RealClubPlayer('Billy Gilmour', 25, 83, 6),
      ],
      'forward': [
        RealClubPlayer('Rasmus Højlund', 23, 86, 19),
        RealClubPlayer('David Neres', 29, 85, 7),
        RealClubPlayer('Matteo Politano', 33, 84, 21),
        RealClubPlayer('Noa Lang', 27, 85, 70),
      ],
    },
    'Tottenham': {
      'goalkeeper': [
        RealClubPlayer('Guglielmo Vicario', 30, 86, 1),
        RealClubPlayer('Antonín Kinský', 23, 80, 31),
      ],
      'defender': [
        RealClubPlayer('Cristian Romero', 28, 88, 17),
        RealClubPlayer('Micky van de Ven', 25, 87, 37),
        RealClubPlayer('Pedro Porro', 27, 86, 23),
        RealClubPlayer('Destiny Udogie', 24, 84, 13),
      ],
      'midfielder': [
        RealClubPlayer('James Maddison', 29, 85, 10),
        RealClubPlayer('Sandro Tonali', 28, 84, 16),
        RealClubPlayer('Dejan Kulusevski', 26, 84, 21),
        RealClubPlayer('Lucas Bergvall', 20, 83, 15),
      ],
      'forward': [
        RealClubPlayer('Dominic Solanke', 29, 84, 19),
        RealClubPlayer('Richarlison', 29, 83, 9),
        RealClubPlayer('Omar Marmush', 27, 84, 22),
        RealClubPlayer('Xavi Simons', 23, 82, 7),
      ],
    },
    'Manchester United': {
      'goalkeeper': [
        RealClubPlayer('André Onana', 30, 84, 24),
        RealClubPlayer('Senne Lammens', 24, 81, 31),
      ],
      'defender': [
        RealClubPlayer('Matthijs de Ligt', 27, 87, 4),
        RealClubPlayer('Lisandro Martínez', 28, 86, 6),
        RealClubPlayer('Harry Maguire', 33, 82, 5),
        RealClubPlayer('Diogo Dalot', 27, 85, 20),
      ],
      'midfielder': [
        RealClubPlayer('Bruno Fernandes', 32, 89, 8),
        RealClubPlayer('Kobbie Mainoo', 21, 81, 37),
        RealClubPlayer('Yuri Tielemans', 29, 83, 18),
        RealClubPlayer('Mason Mount', 27, 83, 7),
      ],
      'forward': [
        RealClubPlayer('Matheus Cunha', 27, 86, 10),
        RealClubPlayer('Bryan Mbeumo', 27, 85, 19),
        RealClubPlayer('Benjamin Šeško', 23, 86, 30),
        RealClubPlayer('Amad Diallo', 24, 85, 16),
      ],
    },
    'Chelsea': {
      'goalkeeper': [
        RealClubPlayer('Robert Sánchez', 28, 83, 1),
        RealClubPlayer('Filip Jørgensen', 24, 81, 12),
      ],
      'defender': [
        RealClubPlayer('Levi Colwill', 23, 85, 6),
        RealClubPlayer('Wesley Fofana', 25, 84, 29),
        RealClubPlayer('Reece James', 26, 87, 24),
        RealClubPlayer('Malo Gusto', 23, 85, 27),
      ],
      'midfielder': [
        RealClubPlayer('Morgan Rogers', 24, 87, 17),
        RealClubPlayer('Moisés Caicedo', 24, 86, 25),
        RealClubPlayer('Cole Palmer', 24, 90, 10),
        RealClubPlayer('Roméo Lavia', 22, 83, 45),
      ],
      'forward': [
        RealClubPlayer('João Pedro', 25, 87, 20),
        RealClubPlayer('Estevao', 19, 83, 41),
        RealClubPlayer('Pedro Neto', 26, 86, 7),
        RealClubPlayer('Danny Welbeck', 35, 82, 18),
      ],
    },
    'Borussia Dortmund': {
      'goalkeeper': [
        RealClubPlayer('Gregor Kobel', 28, 87, 1),
        RealClubPlayer('Alexander Meyer', 35, 78, 33),
      ],
      'defender': [
        RealClubPlayer('Nico Schlotterbeck', 26, 87, 4),
        RealClubPlayer('Waldemar Anton', 30, 84, 3),
        RealClubPlayer('Niklas Süle', 31, 82, 25),
        RealClubPlayer('Julian Ryerson', 28, 83, 26),
      ],
      'midfielder': [
        RealClubPlayer('Marcel Sabitzer', 32, 84, 20),
        RealClubPlayer('Felix Nmecha', 25, 84, 8),
        RealClubPlayer('Julian Brandt', 30, 86, 10),
        RealClubPlayer('Jobe Bellingham', 21, 82, 7),
      ],
      'forward': [
        RealClubPlayer('Serhou Guirassy', 30, 86, 9),
        RealClubPlayer('Fabio Silva', 24, 81, 21),
        RealClubPlayer('Maximilian Beier', 24, 82, 14),
        RealClubPlayer('Jamie Gittens', 22, 84, 43),
      ],
    },
    'Juventus': {
      'goalkeeper': [
        RealClubPlayer('Michele Di Gregorio', 29, 85, 29),
        RealClubPlayer('Mattia Perin', 33, 81, 1),
      ],
      'defender': [
        RealClubPlayer('Bremer', 29, 88, 3),
        RealClubPlayer('Pierre Kalulu', 26, 84, 15),
        RealClubPlayer('Federico Gatti', 28, 83, 4),
        RealClubPlayer('Andrea Cambiaso', 26, 85, 27),
      ],
      'midfielder': [
        RealClubPlayer('Manuel Locatelli', 28, 82, 5),
        RealClubPlayer('Khephren Thuram', 25, 84, 19),
        RealClubPlayer('Teun Koopmeiners', 28, 83, 8),
        RealClubPlayer('Weston McKennie', 28, 83, 22),
      ],
      'forward': [
        RealClubPlayer('Kerim Alajbegovic', 19, 81, 17),
        RealClubPlayer('Kenan Yıldız', 21, 85, 10),
        RealClubPlayer('Francisco Conceição', 23, 85, 7),
        RealClubPlayer('Randal Kolo Muani', 27, 84, 20),
      ],
    },
    'AC Milan': {
      'goalkeeper': [
        RealClubPlayer('Mike Maignan', 31, 88, 16),
        RealClubPlayer('Pietro Terracciano', 36, 79, 1),
      ],
      'defender': [
        RealClubPlayer('Fikayo Tomori', 28, 84, 23),
        RealClubPlayer('Strahinja Pavlović', 25, 84, 31),
        RealClubPlayer('Matteo Gabbia', 26, 82, 46),
        RealClubPlayer('Koni De Winter', 24, 83, 5),
      ],
      'midfielder': [
        RealClubPlayer('Younus Musah', 23, 83, 80),
        RealClubPlayer('Luka Modrić', 41, 85, 14),
        RealClubPlayer('Ruben Loftus-Cheek', 30, 82, 8),
        RealClubPlayer('Adrien Rabiot', 31, 85, 12),
      ],
      'forward': [
        RealClubPlayer('Goncalo Ramos', 25, 84, 9),
        RealClubPlayer('Christian Pulisic', 28, 85, 11),
        RealClubPlayer('Diego Moreira', 22, 85, 22),
        RealClubPlayer('Sameul Chukwueze', 27, 83, 21),
      ],
    },
    'Roma': {
      'goalkeeper': [
        RealClubPlayer('Mile Svilar', 27, 85, 99),
        RealClubPlayer('Pierluigi Gollini', 31, 78, 95),
      ],
      'defender': [
        RealClubPlayer('Gianluca Mancini', 30, 82, 23),
        RealClubPlayer('Evan Ndicka', 27, 83, 5),
        RealClubPlayer('Mario Hermoso', 31, 83, 22),
        RealClubPlayer('Nahuel Molina', 28, 83, 20),
      ],
      'midfielder': [
        RealClubPlayer('Manu Koné', 25, 86, 17),
        RealClubPlayer('Bryan Cristante', 31, 83, 4),
        RealClubPlayer('Lorenzo Pellegrini', 30, 85, 7),
        RealClubPlayer('Niccolò Pisilli', 22, 81, 61),
      ],
      'forward': [
        RealClubPlayer('Paulo Dybala', 32, 86, 21),
        RealClubPlayer('Donyell Mallen', 27, 85, 14),
        RealClubPlayer('Matías Soulé', 23, 84, 18),
        RealClubPlayer('Stephan El Shaarawy', 33, 81, 92),
      ],
    },

    // Составы средних клубов сезона 2026/27. Общие рейтинги — игровые оценки.
    'Newcastle United': {
      'defender': [RealClubPlayer('Sven Botman', 26, 83, 4), RealClubPlayer('Tino Livramento', 23, 82, 2)],
      'midfielder': [RealClubPlayer('Joelinton', 30, 82, 7), RealClubPlayer('Jacob Ramsey', 25, 81, 41), RealClubPlayer('Lewis Miley', 20, 79, 67)],
      'forward': [RealClubPlayer('Yoane Wissa', 30, 83, 9), RealClubPlayer('Anthony Elanga', 24, 82, 19), RealClubPlayer('Harvey Barnes', 28, 83, 11), RealClubPlayer('William Osula', 23, 79, 10)],
    },
    'Brighton': {
      'defender': [RealClubPlayer('Lewis Dunk', 34, 81, 5), RealClubPlayer('Olivier Boscagli', 28, 82, 21)],
      'midfielder': [RealClubPlayer('Mats Wieffer', 26, 81, 27), RealClubPlayer('Yasin Ayari', 23, 80, 26), RealClubPlayer('Matt O'Riley', 26, 82, 33)],
      'forward': [RealClubPlayer('Kaoru Mitoma', 29, 84, 7), RealClubPlayer('Georginio Rutter', 24, 82, 10), RealClubPlayer('Yankuba Minteh', 22, 83, 11), RealClubPlayer('Evan Ferguson', 22, 81, 28)],
    },
    'Aston Villa': {
      'defender': [RealClubPlayer('Matty Cash', 29, 81, 2), RealClubPlayer('Pau Torres', 29, 83, 14)],
      'midfielder': [RealClubPlayer('John McGinn', 31, 82, 7), RealClubPlayer('Amadou Onana', 25, 83, 24), RealClubPlayer('Leon Goretzka', 31, 85, 27)],
      'forward': [RealClubPlayer('Nicolas Jackson', 25, 84, 11), RealClubPlayer('Alejandro Garnacho', 22, 83, 17), RealClubPlayer('Tammy Abraham', 29, 82, 18), RealClubPlayer('Ibrahim Mbaye', 18, 78, 19)],
    },
    'Bayer Leverkusen': {
      'defender': [RealClubPlayer('Jarell Quansah', 23, 83, 4), RealClubPlayer('Edmond Tapsoba', 27, 84, 12)],
      'midfielder': [RealClubPlayer('Malik Tillman', 24, 84, 10), RealClubPlayer('Aleix García', 29, 82, 24), RealClubPlayer('Ibrahim Maza', 20, 82, 30)],
      'forward': [RealClubPlayer('Patrik Schick', 30, 85, 14), RealClubPlayer('Victor Boniface', 25, 83, 22), RealClubPlayer('Nathan Tella', 27, 82, 23), RealClubPlayer('Moussa Diaby', 27, 84, 19)],
    },
    'RB Leipzig': {
      'defender': [RealClubPlayer('Willi Orbán', 33, 83, 4), RealClubPlayer('Maxime Estève', 24, 82, 3)],
      'midfielder': [RealClubPlayer('Nicolas Seiwald', 25, 82, 13), RealClubPlayer('Assan Ouédraogo', 20, 82, 8), RealClubPlayer('Brajan Gruda', 22, 83, 10)],
      'forward': [RealClubPlayer('Antonio Nusa', 21, 84, 7), RealClubPlayer('Johan Bakayoko', 23, 84, 11), RealClubPlayer('Marc Guiu', 20, 81, 9), RealClubPlayer('Christopher Nkunku', 28, 86, 28)],
    },
    'VfB Stuttgart': {
      'defender': [RealClubPlayer('Jeff Chabot', 28, 82, 24), RealClubPlayer('Maximilian Mittelstädt', 29, 83, 7)],
      'midfielder': [RealClubPlayer('Angelo Stiller', 25, 85, 6), RealClubPlayer('Bilal El Khannouss', 22, 83, 11), RealClubPlayer('Chris Führich', 28, 83, 10)],
      'forward': [RealClubPlayer('Ermedin Demirović', 28, 84, 9), RealClubPlayer('Deniz Undav', 30, 85, 26), RealClubPlayer('Tiago Tomás', 24, 81, 8), RealClubPlayer('Jamie Leweling', 25, 83, 18)],
    },
    'Lazio': {
      'defender': [RealClubPlayer('Diogo Leite', 27, 81, 2), RealClubPlayer('Nuno Tavares', 26, 82, 17)],
      'midfielder': [RealClubPlayer('Nicolò Rovella', 24, 83, 6), RealClubPlayer('Davide Frattesi', 26, 84, 16), RealClubPlayer('Kenneth Taylor', 24, 83, 24)],
      'forward': [RealClubPlayer('Mattia Zaccagni', 31, 83, 10), RealClubPlayer('Andrea Pinamonti', 27, 82, 9), RealClubPlayer('Boulaye Dia', 30, 82, 19), RealClubPlayer('Petar Ratkov', 23, 80, 20)],
    },
    'Atalanta': {
      'defender': [RealClubPlayer('Isak Hien', 27, 83, 4), RealClubPlayer('Giorgio Scalvini', 22, 84, 42)],
      'midfielder': [RealClubPlayer('Éderson', 27, 85, 13), RealClubPlayer('Mario Pašalić', 31, 83, 8), RealClubPlayer('Lazar Samardžić', 24, 83, 10)],
      'forward': [RealClubPlayer('Gianluca Scamacca', 27, 84, 9), RealClubPlayer('Charles De Ketelaere', 25, 85, 17), RealClubPlayer('Jonathan Rowe', 22, 82, 11), RealClubPlayer('Giacomo Raspadori', 26, 83, 18)],
    },
    'Fiorentina': {
      'defender': [RealClubPlayer('Dodô', 27, 82, 2), RealClubPlayer('Marin Pongračić', 28, 81, 5)],
      'midfielder': [RealClubPlayer('Nicolò Fagioli', 25, 83, 44), RealClubPlayer('Rolando Mandragora', 29, 81, 8), RealClubPlayer('Cher Ndour', 22, 81, 27)],
      'forward': [RealClubPlayer('Moise Kean', 26, 84, 9), RealClubPlayer('Albert Gudmundsson', 29, 84, 11), RealClubPlayer('Alieu Njie', 21, 79, 25), RealClubPlayer('Wilfried Gnonto', 22, 83, 29)],
    },
    'Lille': {
      'defender': [RealClubPlayer('Nathan Ngoy', 23, 81, 3), RealClubPlayer('Alexsandro', 27, 82, 4)],
      'midfielder': [RealClubPlayer('Nabil Bentaleb', 31, 81, 6), RealClubPlayer('Hákon Haraldsson', 23, 82, 10), RealClubPlayer('Osame Sahraoui', 25, 82, 11)],
      'forward': [RealClubPlayer('Olivier Giroud', 40, 80, 9), RealClubPlayer('Dilane Bakwa', 24, 82, 7), RealClubPlayer('Ayase Ueda', 28, 82, 18), RealClubPlayer('Gaëtan Perrin', 30, 80, 28)],
    },
    'Marseille': {
      'defender': [RealClubPlayer('Leonardo Balerdi', 27, 83, 5), RealClubPlayer('Nayef Aguerd', 30, 84, 21)],
      'midfielder': [RealClubPlayer('Pierre-Emile Højbjerg', 31, 84, 23), RealClubPlayer('Angel Gomes', 26, 82, 7), RealClubPlayer('Tochukwu Nnadi', 23, 79, 6)],
      'forward': [RealClubPlayer('Amine Gouiri', 26, 84, 9), RealClubPlayer('Igor Paixão', 26, 84, 14), RealClubPlayer('Neal Maupay', 30, 81, 11), RealClubPlayer('Faris Moumbagna', 26, 79, 29)],
    },
    'Monaco': {
      'defender': [RealClubPlayer('Vanderson', 25, 83, 2), RealClubPlayer('Mohammed Salisu', 27, 82, 22)],
      'midfielder': [RealClubPlayer('Denis Zakaria', 29, 84, 6), RealClubPlayer('Aleksandr Golovin', 30, 84, 10), RealClubPlayer('Lamine Camara', 22, 83, 8)],
      'forward': [RealClubPlayer('Folarin Balogun', 25, 83, 9), RealClubPlayer('Mika Biereth', 23, 82, 14), RealClubPlayer('Matthis Abline', 23, 82, 11), RealClubPlayer('Ansu Fati', 24, 83, 31)],
    },
    'Strasbourg': {
      'defender': [RealClubPlayer('Andrew Omobamidele', 24, 81, 2), RealClubPlayer('Ben Chilwell', 29, 82, 3)],
      'midfielder': [RealClubPlayer('Giovanni Reyna', 23, 82, 10), RealClubPlayer('Dário Essugo', 21, 81, 14), RealClubPlayer('Maximilian Oyedele', 21, 80, 8)],
      'forward': [RealClubPlayer('Joaquín Panichelli', 24, 82, 9), RealClubPlayer('Conrad Harder', 21, 82, 40), RealClubPlayer('Deivid Washington', 21, 80, 29), RealClubPlayer('Sekou Mara', 24, 79, 7)],
    },
    'Lyon': {
      'defender': [RealClubPlayer('Moussa Niakhaté', 30, 82, 19), RealClubPlayer('Nicolás Tagliafico', 34, 82, 3)],
      'midfielder': [RealClubPlayer('Corentin Tolisso', 32, 83, 8), RealClubPlayer('Tyler Morton', 23, 82, 23), RealClubPlayer('Pavel Šulc', 25, 83, 10)],
      'forward': [RealClubPlayer('Ernest Nuamah', 22, 83, 7), RealClubPlayer('Loïs Openda', 26, 85, 17), RealClubPlayer('Kail Boudache', 20, 78, 26), RealClubPlayer('Rémi Himbert', 18, 77, 45)],
    },
    'Real Betis': {
      'defender': [RealClubPlayer('Natan', 25, 82, 4), RealClubPlayer('Marc Bartra', 35, 81, 5)],
      'midfielder': [RealClubPlayer('Pablo Fornals', 30, 83, 8), RealClubPlayer('Isco', 34, 85, 22), RealClubPlayer('Giovani Lo Celso', 30, 84, 20)],
      'forward': [RealClubPlayer('Antony', 26, 84, 7), RealClubPlayer('Cucho Hernández', 27, 83, 9), RealClubPlayer('Abde Ezzalzouli', 24, 83, 10), RealClubPlayer('Troy Parrott', 24, 81, 19)],
    },
    'Real Sociedad': {
      'defender': [RealClubPlayer('Igor Zubeldia', 29, 82, 5), RealClubPlayer('Jon Aramburu', 24, 81, 2)],
      'midfielder': [RealClubPlayer('Beñat Turrientes', 24, 81, 8), RealClubPlayer('Jon Gorrotxategi', 24, 80, 4), RealClubPlayer('Carlos Soler', 29, 83, 18)],
      'forward': [RealClubPlayer('Mikel Oyarzabal', 29, 85, 10), RealClubPlayer('Orri Óskarsson', 21, 82, 9), RealClubPlayer('Takefusa Kubo', 25, 85, 14), RealClubPlayer('Gonçalo Guedes', 29, 82, 11)],
    },
    'Sevilla': {
      'defender': [RealClubPlayer('Juan Iglesias', 28, 80, 2), RealClubPlayer('José Ángel Carmona', 24, 81, 22)],
      'midfielder': [RealClubPlayer('Lucien Agoumé', 24, 81, 6), RealClubPlayer('Jon Guridi', 31, 80, 18), RealClubPlayer('Giorgi Kochorashvili', 27, 80, 8)],
      'forward': [RealClubPlayer('Robbie Ure', 22, 78, 9), RealClubPlayer('Peque Fernández', 23, 80, 10), RealClubPlayer('Alfon González', 27, 80, 7), RealClubPlayer('Isaac Romero', 26, 82, 16)],
    },
    'Villarreal': {
      'defender': [RealClubPlayer('Pau Navarro', 21, 81, 26), RealClubPlayer('Renato Veiga', 23, 83, 12)],
      'midfielder': [RealClubPlayer('Dani Parejo', 37, 82, 10), RealClubPlayer('Santi Comesaña', 29, 81, 14), RealClubPlayer('Alberto Moleiro', 23, 84, 10)],
      'forward': [RealClubPlayer('Ayoze Pérez', 33, 83, 22), RealClubPlayer('Gerard Moreno', 34, 84, 7), RealClubPlayer('Georges Mikautadze', 26, 84, 9), RealClubPlayer('Ilias Akhomach', 22, 81, 11)],
    },
    'Athletic Bilbao': {
      'defender': [RealClubPlayer('Dani Vivian', 27, 84, 3), RealClubPlayer('Aitor Paredes', 26, 82, 4)],
      'midfielder': [RealClubPlayer('Beñat Prados', 25, 82, 6), RealClubPlayer('Oihan Sancet', 26, 84, 8), RealClubPlayer('Peio Canales', 21, 79, 28)],
      'forward': [RealClubPlayer('Nico Williams', 24, 86, 10), RealClubPlayer('Gorka Guruzeta', 29, 82, 12), RealClubPlayer('Iñaki Williams', 32, 85, 9), RealClubPlayer('Alex Berenguer', 31, 82, 7)],
    },
    'Zenit': {
      'defender': [RealClubPlayer('Nino', 29, 83, 33), RealClubPlayer('Igor Diveev', 27, 84, 78)],
      'midfielder': [RealClubPlayer('Wendel', 29, 84, 8), RealClubPlayer('Wilmar Barrios', 33, 83, 5), RealClubPlayer('Luiz Henrique', 25, 84, 11)],
      'forward': [RealClubPlayer('Aleksandr Sobolev', 29, 82, 7), RealClubPlayer('Felipe Augusto', 22, 81, 9), RealClubPlayer('Maksim Glushenkov', 27, 84, 10), RealClubPlayer('Pedro Henrique', 20, 80, 20)],
    },
    'CSKA Moscow': {
      'defender': [RealClubPlayer('Milan Gajić', 30, 81, 22), RealClubPlayer('Matheus Reis', 31, 82, 2)],
      'midfielder': [RealClubPlayer('Matvey Kislyak', 21, 83, 31), RealClubPlayer('Ivan Oblyakov', 28, 84, 10), RealClubPlayer('Danila Kozlov', 21, 81, 18)],
      'forward': [RealClubPlayer('Luciano Gondou', 25, 83, 32), RealClubPlayer('Tamerlan Musaev', 25, 80, 11), RealClubPlayer('Maksim Voronov', 19, 78, 97), RealClubPlayer('Kirill Glebov', 20, 81, 17)],
    },
    'Spartak Moscow': {
      'defender': [RealClubPlayer('Christopher Wu', 25, 82, 3), RealClubPlayer('Srdjan Babić', 30, 82, 6)],
      'midfielder': [RealClubPlayer('Esequiel Barco', 27, 85, 5), RealClubPlayer('Nail Umyarov', 26, 81, 18), RealClubPlayer('Roman Zobnin', 32, 81, 47)],
      'forward': [RealClubPlayer('Manfred Ugalde', 24, 84, 9), RealClubPlayer('Marquinhos', 27, 82, 10), RealClubPlayer('Pablo Solari', 25, 82, 7), RealClubPlayer('Theo Bongonda', 30, 81, 77)],
    },
    'Krasnodar': {
      'defender': [RealClubPlayer('Vítor Tormena', 30, 82, 3), RealClubPlayer('Jubal', 33, 81, 5)],
      'midfielder': [RealClubPlayer('Douglas Augusto', 29, 82, 8), RealClubPlayer('Aleksandr Chernikov', 26, 81, 53), RealClubPlayer('Magomed Ozdoev', 33, 82, 21)],
      'forward': [RealClubPlayer('Jhon Córdoba', 33, 85, 9), RealClubPlayer('Dmitry Vorobyov', 28, 81, 10), RealClubPlayer('Juan Boselli', 27, 80, 23), RealClubPlayer('Batxi', 28, 81, 11)],
    },
    'Lokomotiv Moscow': {
      'defender': [RealClubPlayer('Zherzino Nyamsi', 29, 81, 5), RealClubPlayer('Lucas Fasson', 25, 80, 3)],
      'midfielder': [RealClubPlayer('Sergey Babkin', 24, 79, 6), RealClubPlayer('Sergey Pinyaev', 21, 83, 9), RealClubPlayer('Zelimkhan Bakaev', 30, 81, 7)],
      'forward': [RealClubPlayer('Nikolay Komlichenko', 31, 81, 27), RealClubPlayer('Vadim Rakov', 21, 80, 11), RealClubPlayer('Aleksandr Rudenko', 27, 80, 19), RealClubPlayer('Ruslan Mialkovsky', 22, 78, 99)],
    },
    'Dynamo Makhachkala': {
      'defender': [RealClubPlayer('Idar Shumakhov', 27, 78, 4), RealClubPlayer('Soslan Kagermazov', 29, 77, 13)],
      'midfielder': [RealClubPlayer('Marat Apshatsev', 25, 78, 6), RealClubPlayer('Hussem Mrezig', 26, 78, 16), RealClubPlayer('Vladimir Khubulov', 25, 78, 8)],
      'forward': [RealClubPlayer('Miro', 27, 78, 11), RealClubPlayer('Gamid Agalarov', 26, 79, 25), RealClubPlayer('Serder Serderov', 31, 77, 28), RealClubPlayer('Daniil Lesovoy', 28, 79, 88)],
    },
    'Dynamo Moscow': {
      'defender': [RealClubPlayer('Nicolas Marichal', 25, 82, 2), RealClubPlayer('Maksim Osipenko', 32, 83, 55)],
      'midfielder': [RealClubPlayer('Bitello', 26, 84, 10), RealClubPlayer('Daniil Fomin', 29, 82, 74), RealClubPlayer('Anton Miranchuk', 31, 82, 21)],
      'forward': [RealClubPlayer('Konstantin Tyukavin', 24, 85, 70), RealClubPlayer('Ivan Sergeev', 31, 81, 33), RealClubPlayer('Arthur Gomes', 28, 81, 11), RealClubPlayer('Josue Casimir', 25, 80, 77)],
    },
    'Ajax': {
      'defender': [RealClubPlayer('Youri Baas', 23, 82, 15), RealClubPlayer('Ko Itakura', 29, 83, 4)],
      'midfielder': [RealClubPlayer('Julian Brandt', 30, 85, 8), RealClubPlayer('Oscar Gloukh', 22, 84, 10), RealClubPlayer('Davy Klaassen', 33, 82, 18)],
      'forward': [RealClubPlayer('Kasper Dolberg', 29, 83, 9), RealClubPlayer('Oliver Edvardsen', 27, 80, 20), RealClubPlayer('Marcos Leonardo', 23, 84, 38), RealClubPlayer('Toluwalase Arokodare', 25, 81, 99)],
    },
    'PSV': {
      'defender': [RealClubPlayer('Lutsharel Geertruida', 26, 83, 2), RealClubPlayer('Yarek Gasiorowski', 21, 82, 3)],
      'midfielder': [RealClubPlayer('Paul Wanner', 20, 83, 10), RealClubPlayer('Guus Til', 28, 83, 20), RealClubPlayer('Sven Mijnans', 26, 82, 21)],
      'forward': [RealClubPlayer('Ricardo Pepi', 23, 83, 9), RealClubPlayer('Ivan Perišić', 37, 82, 5), RealClubPlayer('Dennis Man', 28, 83, 27), RealClubPlayer('Ruben van Bommel', 22, 81, 7)],
    },
    'Feyenoord': {
      'defender': [RealClubPlayer('Tsuyoshi Watanabe', 29, 82, 4), RealClubPlayer('Jordan Bos', 23, 81, 15)],
      'midfielder': [RealClubPlayer('Sem Steijn', 24, 84, 14), RealClubPlayer('Luciano Valente', 23, 82, 10), RealClubPlayer('Jakub Moder', 27, 82, 7)],
      'forward': [RealClubPlayer('Anis Hadj Moussa', 24, 84, 23), RealClubPlayer('Reiss Nelson', 26, 82, 17), RealClubPlayer('Gonçalo Borges', 27, 81, 11), RealClubPlayer('Gaoussou Diarra', 22, 78, 27)],
    },
    'Club Brugge': {
      'defender': [RealClubPlayer('Joel Ordóñez', 22, 83, 4), RealClubPlayer('Brandon Mechele', 33, 82, 44)],
      'midfielder': [RealClubPlayer('Hans Vanaken', 34, 84, 20), RealClubPlayer('Hugo Vetlesen', 26, 82, 10), RealClubPlayer('Freddie Potts', 23, 80, 8)],
      'forward': [RealClubPlayer('Nicolò Tresoldi', 22, 83, 7), RealClubPlayer('Carlos Forbs', 22, 82, 9), RealClubPlayer('Romeo Vermant', 22, 80, 17), RealClubPlayer('Jan Virgili', 21, 80, 11)],
    },
    'Union Saint-Gilloise': {
      'defender': [RealClubPlayer('Kevin Mac Allister', 28, 81, 5), RealClubPlayer('Ross Sykes', 27, 80, 26)],
      'midfielder': [RealClubPlayer('Adem Zorgane', 26, 82, 8), RealClubPlayer('Besfort Zeneli', 23, 80, 23), RealClubPlayer('Rob Schoofs', 32, 81, 17)],
      'forward': [RealClubPlayer('Promise David', 25, 82, 12), RealClubPlayer('Mohammed Fuseini', 24, 80, 7), RealClubPlayer('Kevin Rodríguez', 26, 81, 13), RealClubPlayer('Raúl Florucz', 25, 80, 30)],
    },
    'Benfica': {
      'defender': [RealClubPlayer('Clément Lenglet', 31, 83, 2), RealClubPlayer('Alexander Bah', 28, 82, 6)],
      'midfielder': [RealClubPlayer('Fredrik Aursnes', 30, 84, 8), RealClubPlayer('Georgiy Sudakov', 24, 85, 10), RealClubPlayer('Leandro Barreiro', 27, 82, 18)],
      'forward': [RealClubPlayer('Vangelis Pavlidis', 27, 85, 14), RealClubPlayer('Dodi Lukébakio', 29, 84, 11), RealClubPlayer('Franjo Ivanović', 22, 82, 9), RealClubPlayer('Andreas Schjelderup', 22, 82, 21)],
    },
    'Sporting CP': {
      'defender': [RealClubPlayer('Zeno Debast', 23, 83, 6), RealClubPlayer('Gonçalo Inácio', 25, 85, 25)],
      'midfielder': [RealClubPlayer('Rodrigo Zalazar', 27, 83, 17), RealClubPlayer('João Simões', 19, 81, 8), RealClubPlayer('Pedro Lima', 20, 79, 21)],
      'forward': [RealClubPlayer('Luis Suárez', 28, 85, 97), RealClubPlayer('Fotis Ioannidis', 26, 83, 7), RealClubPlayer('Geny Catamo', 25, 82, 10), RealClubPlayer('Nuno Santos', 31, 81, 11)],
    },
    'Porto': {
      'defender': [RealClubPlayer('Jakub Kiwior', 26, 84, 4), RealClubPlayer('Jan Bednarek', 30, 83, 5)],
      'midfielder': [RealClubPlayer('Victor Froholdt', 20, 82, 8), RealClubPlayer('Alan Varela', 25, 84, 22), RealClubPlayer('Seko Fofana', 31, 83, 42)],
      'forward': [RealClubPlayer('Samu Aghehowa', 22, 85, 9), RealClubPlayer('Santiago Giménez', 25, 84, 29), RealClubPlayer('William Gomes', 20, 81, 7), RealClubPlayer('Pepê', 29, 83, 11)],
    },
    'Braga': {
      'defender': [RealClubPlayer('Sikou Niakaté', 27, 81, 4), RealClubPlayer('Victor Gómez', 26, 80, 2)],
      'midfielder': [RealClubPlayer('João Moutinho', 40, 80, 8), RealClubPlayer('Mahamadou Dorgeles', 22, 81, 20), RealClubPlayer('Denis Huseinbašić', 25, 81, 23)],
      'forward': [RealClubPlayer('Ricardo Horta', 31, 85, 21), RealClubPlayer('Fran Navarro', 28, 81, 9), RealClubPlayer('Pau Víctor', 24, 82, 10), RealClubPlayer('Gabriel Silva', 24, 80, 11)],
    },
    'Fenerbahce': {
      'defender': [RealClubPlayer('Nathan Aké', 31, 85, 15), RealClubPlayer('Milan Škriniar', 31, 84, 37)],
      'midfielder': [RealClubPlayer('Mattéo Guendouzi', 27, 85, 6), RealClubPlayer('N’Golo Kanté', 35, 84, 91), RealClubPlayer('İsmail Yüksek', 27, 82, 5)],
      'forward': [RealClubPlayer('Mason Greenwood', 25, 85, 11), RealClubPlayer('Romelu Lukaku', 33, 84, 9), RealClubPlayer('Kerem Aktürkoğlu', 28, 83, 7), RealClubPlayer('Dorgeles Nene', 24, 81, 45)],
    },
    'Galatasaray': {
      'defender': [RealClubPlayer('Davinson Sánchez', 30, 84, 6), RealClubPlayer('Wilfried Singo', 25, 83, 90)],
      'midfielder': [RealClubPlayer('Gabriel Sara', 27, 84, 8), RealClubPlayer('Lucas Torreira', 30, 83, 34), RealClubPlayer('İlkay Gündoğan', 36, 84, 20)],
      'forward': [RealClubPlayer('Victor Osimhen', 27, 88, 45), RealClubPlayer('Leroy Sané', 30, 85, 10), RealClubPlayer('Rafael Leão', 27, 87, 27), RealClubPlayer('Yunus Akgün', 26, 82, 11)],
    },
  };
}
