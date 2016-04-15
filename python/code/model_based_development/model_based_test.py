from __future__ import division
import time
import numpy as np
import matplotlib.pyplot as plt
from QLearning import QLearning
from Dyna import Dyna
from Sarsa import Sarsa
from RLEnvironment import RLEnvironment

config = {
    'episodes': None,
    'trials': None,
    'epsilon': None,
    'alpha': None,
    'gamma': None,
    'k': None,
    'initial_Q': None,
    'nActions': None,
    'PLOTS': None,
    'PLOT_TRAJECTORIES': None,
    'INITIAL_POSITION_RANDOM': None}


def plot_figure_update(s, ep, tr, alg, step):
    ax.clear()
    ax.plot(s[1], s[0], 'xr', markersize=30, color='red')
    ax.imshow(Env.world, interpolation='nearest', cmap=plt.get_cmap('Blues'))
    ax.set_title('Trial: {0} - Episode: {1} \n Algorithm: {2} \n  Step: {3}'.format(tr, ep, alg, step))
    ax.get_xaxis().set_ticks(range(Env.cols))
    ax.get_yaxis().set_ticks(range(Env.rows))
    plt.draw()
    plt.pause(0.0001)


def load_config(config_file):
    with open(config_file, 'r') as cf:
        for line in cf:
            if line[0] != "#" and len(line) > 1:
                line = line.split('=')
                identifier = line[0].strip()
                if identifier in ['alpha', 'epsilon', 'gamma', 'initialQ']:
                    config[identifier] = float(line[1].strip())
                else:
                    config[identifier] = int(line[1].strip())


def exec_episode(model, model_name):

    step_counter = 0
    model.set_current_state(np.copy(init_rand_state))

    while not Env.is_final_state(model.current_state, Env.win_state):
        step_counter += 1

        if np.random.rand() < config['epsilon']:
            model.set_action(int(np.floor(np.random.rand() * config['nActions'])))
        else:
            action = model.pick_random_best_action(model.Q[Env.linearize(model.current_state, Env.cols)])
            model.set_action(action)

        model.set_next_state(Env.get_next_state(model.action, model.current_state))

        # get_reward moves the agent back if it hits the walls
        # no idea how. tried to replicate but could not
        model.set_reward(Env.get_reward(model.next_state, model.current_state, Env.world))

        state_lin = Env.linearize(model.current_state, Env.cols)
        next_state_lin = Env.linearize(model.next_state, Env.cols)

        model.update_Q(state_lin, next_state_lin, config['alpha'], config['gamma'], config['k'], Env.nStates,
                       config['nActions'])

        model.set_current_state(model.next_state)
        # model.print_Q()

        if config['PLOTS']:
            plot_figure_update(model.current_state, episode, trial, model_name, step_counter)

    counter[model_name].append(step_counter)

if __name__ == '__main__':

    start_time = time.time()

    load_config('config_file')

    Env = RLEnvironment(10, 0, 0, 'world_file', 100)

    steps = {'mb': [], 'ql': [], 'ss': []}

    if config['PLOTS']:
        plt.ion()
        plt.close('all')

        fig = plt.figure()
        ax = fig.add_subplot(111)
        plt.show()

    for trial in range(config['trials']):
        trial_time = time.time()

        counter = {'mb': [], 'ql': [], 'ss': []}

        MB = Dyna(config['nActions'], Env.nStates, config['initial_Q'])
        QL = QLearning(config['nActions'], Env.nStates, config['initial_Q'])
        SS = Sarsa(config['nActions'], Env.nStates, config['initial_Q'])

        for episode in range(config['episodes']):

            if config['INITIAL_POSITION_RANDOM']:
                init_rand_state = Env.randomise_initial_state(Env.cols, Env.rows)
            else:
                init_rand_state = np.array([0, 0])

            exec_episode(MB, 'mb')
            exec_episode(QL, 'ql')
            exec_episode(SS, 'ss')

        # store counter for nth trial
        steps['mb'].append(counter['mb'])
        steps['ql'].append(counter['ql'])
        steps['ss'].append(counter['ss'])

        print 'trial {0} : {1:.3f} sec(s)'.format(trial, time.time() - trial_time)

    print 'elapsed time', time.time() - start_time

    if config['INITIAL_POSITION_RANDOM']:
        avg_steps = ((Env.rows / 2) + (Env.cols / 2) - 1)
    else:
        avg_steps = Env.rows - 1 + Env.cols - 1
    print 'avg steps to winning state', avg_steps

    if config['PLOTS']:
        plt.waitforbuttonpress()

    if MB:
        plt.plot(np.arange(config['episodes']), [sum(i)/config['trials']
                                                 for i in zip(*steps['mb'])], color='red', label='Model Based')
    if QL:
        plt.plot(np.arange(config['episodes']), [sum(i)/config['trials']
                                                 for i in zip(*steps['ql'])], color='green', label='Q-learning')
    if SS:
        plt.plot(np.arange(config['episodes']), [sum(i)/config['trials']
                                                 for i in zip(*steps['ss'])], color='blue', label='Sarsa')

    plt.plot(np.arange(config['episodes']), np.ones(config['episodes'])*avg_steps,
             color='black', label='average min steps')
    plt.title(" Rand Init: {0} \t Env stochastic penalty: {1} \n"
              " Eps: {2} - k: {3} - Episodes: {4} - Trials: {5} \n"
              " World Size {6}x{7}".
              format(config['INITIAL_POSITION_RANDOM'], Env.STOCHASTIC_PENALTY_PROB,
                     config['epsilon'], config['k'], config['episodes'], config['trials'], Env.rows, Env.cols))
    plt.legend()
    plt.show()

    if config['PLOT_TRAJECTORIES']:
        if MB:
            for trajectory in steps['mb']:
                plt.plot(np.arange(config['episodes']), trajectory, color='red', label='Model Based')
        if QL:
            for trajectory in steps['ql']:
                plt.plot(np.arange(config['episodes']), trajectory, color='green', label='Q-learning')
        if SS:
            for trajectory in steps['ss']:
                plt.plot(np.arange(config['episodes']), trajectory, color='blue', label='Sarsa')

        plt.plot(np.arange(config['episodes']), np.ones(config['episodes'])*((Env.rows/2) + (Env.cols/2) - 1),
                 color='black', label='average min steps')
        plt.show()
